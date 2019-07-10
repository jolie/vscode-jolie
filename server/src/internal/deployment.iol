include "interfaces/lsp.iol"

//location sent by the client
constants {
  Location_JolieLS = "",
  Debug = false
}

outputPort TextDocument {
  Interfaces: TextDocumentInterface
}

outputPort Workspace {
  Interfaces: WorkspaceInterface
}

embedded {
  Jolie: "internal/text_document.ol" in TextDocument,
         "internal/workspace.ol" in Workspace,
         "internal/utils.ol"
}

inputPort Input {
  //Location: "socket://localhost:8080"
  Location: Location_JolieLS
  Protocol: jsonrpc { //.debug = true
    clientLocation -> global.clientLocation
    clientOutputPort = "Client"
    transport = "lsp"
    osc.onExit.alias = "exit"
    osc.cancelRequest.alias = "$/cancelRequest"
    osc.didOpen.alias = "textDocument/didOpen"
    osc.didChange.alias = "textDocument/didChange"
    osc.willSave.alias = "textDocument/willSave"
    osc.didSave.alias = "textDocument/didSave"
    osc.didClose.alias = "textDocument/didClose"
    osc.completion.alias = "textDocument/completion"
    osc.hover.alias = "textDocument/hover"
    osc.documentSymbol.alias = "textDocument/documentSymbol"
    osc.publishDiagnostics.alias = "textDocument/publishDiagnostics"
    osc.publishDiagnostics.isNullable = true
    osc.signatureHelp.alias = "textDocument/signatureHelp"
    osc.didChangeWatchedFiles.alias = "workspace/didChangeWatchedFiles"
    osc.didChangeWorkspaceFolders.alias = "workspace/didChangeWorkspaceFolders"
    osc.didChangeConfiguration.alias = "workspace/didChangeConfiguration"
    osc.symbol.alias = "workspace/symbol"
    osc.executeCommand.alias = "workspace/executeCommand"
    debug = Debug
    debug.showContent = Debug
  }
  Interfaces: GeneralInterface
  Aggregates: TextDocument, Workspace
}


/*
 * port that points to the client, used for publishing diagnostics
 */
outputPort Client {
  Protocol: jsonrpc {
    transport = "lsp"
    debug = Debug
    debug.showContent = Debug
  }
  Interfaces: ServerToClient
}

/*
 * port in which we receive the messages to be forwarded to the client
 */
inputPort NotificationsToClient {
  Location: "local://Client"
  Interfaces: ServerToClient
}
