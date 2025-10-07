import { dirname } from "path";
import * as semver from "semver";
import {
  ExtensionContext,
  OutputChannel,
  ShellExecution,
  Task,
  tasks,
  Uri,
  window,
  workspace,
  TaskScope,
} from "vscode";

import {
  CloseAction,
  CloseHandlerResult,
  ErrorAction,
  ErrorHandlerResult,
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
  Trace,
} from "vscode-languageclient/node";
import LanguageServerProcess, { ServerError } from "./ls_process";
import { spawnSync } from "child_process";
import { createServer, Socket } from "net";
import { lookpath } from "lookpath";
const isWindows = process.platform === "win32";

let server: LanguageServerProcess;
let client: LanguageClient;
let logger: OutputChannel;
let socket: Socket;

const versionRequirement = [
  [">=1.10.1 <1.11.0", "~0.2.1"],
  [">=1.11.0 <1.13.3", "~2.0.0"],
  [">=1.13.3", "~3.0.1"],
];
let languageServerVersion: string;

function createRunTask(title: string): Task {
  const file = window.activeTextEditor!.document.fileName;
  const dir = dirname(file);
  return new Task(
    { type: "run", task: "runJolie" },
    TaskScope.Workspace,
    title,
    "Jolie",
    new ShellExecution(`jolie "${file}"`, { cwd: dir }),
    []
  );
}

async function checkCommandsAvailable(command: string) {
  return (await lookpath(command)) !== undefined;
}

async function checkRequiredJolieVersion(): Promise<void> {
  let p;
  try {
    p = spawnSync("jolie --version", { encoding: "utf8", shell: true });
  } catch (err) {
    const e = err as Error;
    throw new Error(
      "Could not start the Jolie interpreter. Please check that the jolie executable is installed.",
      { cause: e }
    );
  }
  const result = p.stderr.match(/Jolie\s+(\d+\.\d+\.\d+).+/);
  if (Array.isArray(result) && result.length > 1) {
    const jolieVersion = result![1];
    const index = versionRequirement.length - 1;
    for (let i = index; i >= 0; i--) {
      if (semver.satisfies(jolieVersion, versionRequirement[i][0])) {
        languageServerVersion = versionRequirement[i][1];
        break;
      }
    }
    if (!languageServerVersion) {
      throw new Error(
        `This extension requires Jolie version ${versionRequirement[0][0]} or newer, whereas your version is ${jolieVersion}. Some features may not work correctly. Please consider updating your Jolie installation.`
      );
    }
  } else {
    throw new Error(
      `Could not detect the version of the Jolie interpreter. Output of "jolie --version": ${p.stderr}`
    );
  }
}

function registerTasks() {
  tasks.registerTaskProvider("run", {
    provideTasks: () => {
      return [createRunTask("Run current Jolie program")];
    },
    resolveTask(task: Task): Task | undefined {
      return task;
    },
  });
}

function log(message: string) {
  if (
    workspace.getConfiguration().get("jolie.languageServer.showDebugMessages")
  ) {
    logger.appendLine("vscode-jolie lsp client: " + message);
  }
}

async function checkPortAvailable(port: number): Promise<boolean> {
  return new Promise((resolve) => {
    const s = createServer();

    s.once("error", function (err) {
      if (err.message.includes("EADDRINUSE")) {
        resolve(false);
      }
    });
    s.once("listening", function () {
      s.close(() => resolve(true));
    });

    s.listen(port);
  });
}

function createLSServer(tcpPort: number) {
  server = new LanguageServerProcess(
    languageServerVersion,
    tcpPort,
    window.createOutputChannel("Jolie LSP Server"),
    isWindows
  );

  server.on("error", (err: ServerError) => {
    const message =
      "JolieLS: error occur " +
      err.error.message +
      ", try to reconnect = " +
      err.should_retry;
    window.showErrorMessage(message);
    if (!err.should_retry) {
      client.stop();
    }
  });

  return server;
}

export async function activate(_context: ExtensionContext) {
  logger = window.createOutputChannel("Jolie LSP Client");
  for (const command of ["npx", "jolie"]) {
    if (!(await checkCommandsAvailable(command))) {
      const message = `Command "${command}" not found in path variable. Please install before using this extension.`;
      log(message);
      window.showErrorMessage(message);
      return;
    }
  }
  await checkRequiredJolieVersion();
  registerTasks();

  const tcpPort: number = <number>(
    workspace.getConfiguration().get("jolie.languageServer.tcpPort")
  );

  const isPortAvailable = await checkPortAvailable(tcpPort);

  socket = new Socket();
  socket.on("data", (data) => {
    if (
      workspace.getConfiguration().get("jolie.languageServer.showDebugMessages")
    ) {
      log("receive data from Jolie: " + data);
    }
  });

  const serverStreamInfo: ServerOptions = () => {
    return new Promise((resolve) => {
      if (isPortAvailable && process.env.LANGUAGE_SERVER !== "external") {
        log("Start Jolie Language Server.");
        const server = createLSServer(tcpPort);
        server.start();
        server.on("ready", () => {
          socket.connect({ host: "localhost", port: tcpPort });
          resolve({ reader: socket, writer: socket });
        });
      } else {
        log(
          `Start Jolie Language Server: port ${tcpPort}, is not available, try to connect to existing server.`
        );
        socket.connect({ host: "localhost", port: tcpPort });
        resolve({ reader: socket, writer: socket });
      }
    });
  };

  const clientOptions: LanguageClientOptions = {
    documentSelector: [
      { scheme: "file", language: "jolie" },
      { scheme: "untitled", language: "jolie" },
    ],
    synchronize: {
      // configurationSection: 'jolie',
      fileEvents: workspace.createFileSystemWatcher("**/*.{ol,iol}"),
    },
    middleware: {
      // Documents need to be saved, as the rename function uses the text saved on disc
      provideRenameEdits: async (document, position, newName, token, next) => {
        const allSaved = await workspace.saveAll(false);
        if (allSaved) {
          //allSaved is false if some documents couldn't be saved
          return next(document, position, newName, token);
        } else {
          window.showInformationMessage(
            "Some documents could not be saved before, rename was abandoned."
          );
        }
      },
    },
    uriConverters: {
      // See https://github.com/Microsoft/vscode-languageserver-node/issues/105
      code2Protocol: (uri) => {
        return isWindows ? uri.toString().replace("%3A", ":") : uri.toString();
      },
      protocol2Code: (str) => {
        return Uri.parse(str);
      },
    },
    errorHandler: {
      closed(): CloseHandlerResult {
        return {
          action: CloseAction.Restart,
        };
      },

      error(error): ErrorHandlerResult {
        if (error.message.includes("ECONNREFUSED")) {
          const message = `Unable to connect to Jolie Language Server, please make sure the Jolie Language Server is running on port ${tcpPort}.`;
          log(message);
          return {
            action: ErrorAction.Shutdown,
            message: message,
            handled: true,
          };
        } else {
          log("unhandled error");
          return {
            action: ErrorAction.Continue,
            message: error.message,
          };
        }
      },
    },
  };
  client = new LanguageClient(
    "vscode-jolie",
    "Jolie LanguageClient",
    serverStreamInfo,
    clientOptions
  );
  if (
    workspace.getConfiguration().get("jolie.languageServer.showDebugMessages")
  ) {
    await client.setTrace(Trace.Verbose);
  }
  await client.start();

  return;
}

export async function deactivate(): Promise<void | undefined> {
  socket.removeAllListeners();
  socket.destroy();
  server?.kill();
  return client?.stop();
}
