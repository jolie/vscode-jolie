import { ChildProcessWithoutNullStreams, spawn, spawnSync } from "child_process";
import { EventEmitter } from "node:events";
import { OutputChannel, window } from "vscode";

export interface ServerError {
  error: Error;
  description: string;
  should_retry: boolean;
}

export default class LanguageServerProcess extends EventEmitter {
  command: string;
  args: string[];
  port: number;
  logger: OutputChannel;
  proc: ChildProcessWithoutNullStreams | undefined;
  isWindows: boolean;
  public constructor(
    languageServerVersion: string,
    port: number,
    logger: OutputChannel,
    isWindows: boolean
  ) {
    super({ captureRejections: true });
    const languageServer = process.env.LANGUAGE_SERVER;
    if (!languageServer) {
      if (isWindows) {
        this.command = "cmd.exe";
        this.args = [
          "/C",
          "npx",
          "--yes",
          "--package=@jolie/languageserver@" + languageServerVersion,
          "joliels",
          `${port}`,
        ];
      } else {
        this.command = "npx";
        this.args = [
          "--yes",
          "--package=@jolie/languageserver@" + languageServerVersion,
          "joliels",
          `${port}`,
        ];
      }
    } else {
      // languageServer is a path to launcher
      if (isWindows) {
        this.command = "cmd.exe";
        this.args = ["/C", "jolie", "--trace", languageServer, `${port}`];
      } else {
        this.command = "jolie";
        this.args = ["--trace", languageServer, `${port}`];
      }
    }
    logger.appendLine(
      "Start LS Process with command " +
      this.command +
      " " +
      this.args.join(" ")
    );
    this.logger = logger;
    this.port = port;
    this.isWindows = isWindows;
  }

  onReceiveFromJolie = (message: string): void => {
    if (message.includes("Jolie Language Server started")) {
      this.emit("ready");
    } else if (!this._shouldIgnoreMessage(message)) {
      const error = this._processErrorMessage(message);
      if (error) {
        this.emit("error", error);
        this.logger.appendLine(message);
      } else {
        this.logger.appendLine(message);
      }
    }
  };

  _ignoreMessages: string[] = [
    "java.io.IOException: java.nio.channels.IllegalBlockingModeException",
  ];

  _shouldIgnoreMessage(message: string) {
    for (const ignore of this._ignoreMessages) {
      if (message.includes(ignore)) {
        return true;
      }
    }
  }

  _processErrorMessage = (errorMessage: string): ServerError | undefined => {
    const error = new Error(errorMessage);
    if (errorMessage.includes("Rename abandoned.")) {
      return {
        error,
        description: "Rename abandoned.",
        should_retry: false,
      };
    }
    if (errorMessage.includes("service initialisation failed")) {
      return {
        error,
        description: "Jolie Language Server is not running.",
        should_retry: false,
      };
    }
    if (errorMessage.includes("Address already in use")) {
      return {
        error,
        description: `Please check that the TCP port ${this.port} of the local machine is free. Alternatively, you can change the TCP port number under the Jolie Language Support extension configuration. After the change, remember to reboot your editor.`,
        should_retry: false,
      };
    }

    return;
  };

  start = () => {
    // spawn a new process with the command and arguments
    this.proc = spawn(this.command, this.args);
    this.proc.stdout.setEncoding("utf-8");
    this.proc.stderr.setEncoding("utf-8");
    // listen to the stdout and stderr events
    this.proc.stdout.on("data", this.onReceiveFromJolie);
    this.proc.stderr.on("data", this.onReceiveFromJolie);
    // listen to the exit event
    this.proc.on("exit", (_code) => {
      this.emit("end");
    });
  };

  kill = () => {
    if (this.proc) {
      this.proc.stdin.destroy();
      this.proc.stdout.destroy();
      this.proc.stderr.destroy();
      if (this.isWindows) { // Windows doesn't terminate child process properly https://stackoverflow.com/questions/32705857/cant-kill-child-process-on-windows
        spawnSync("taskkill", ["/pid", this.proc.pid!.toString(), '/f', '/t']);
      } else {
        this.proc.kill("SIGINT");

      }
    }
  };
}
