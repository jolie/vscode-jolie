include "types/lsp.iol"

interface GeneralInterface {
  OneWay:
    initialized( InitializedParams ),
    onExit( void ),
    cancelRequest
  RequestResponse:
    initialize( InitializeParams )( InitializeResult ),
    shutdown( void )( void )
}

interface TextDocumentInterface {
  OneWay:
    didOpen( DidOpenTextDocumentParams ),
    didChange( DidChangeTextDocumentParams ),
    willSave( WillSaveTextDocumentParams ),
    didSave( DidSaveTextDocumentParams ),
    didClose( DidCloseTextDocumentParams )
  RequestResponse:
    willSaveWaitUntil( WillSaveTextDocumentParams )( WillSaveWaitUntilResponse ),
    completion( CompletionParams )( CompletionResult ),
    hover( TextDocumentPositionParams )( HoverInformations ),
    documentSymbol( DocumentSymbolParams )( DocumentSymbolResult ),
    signatureHelp( TextDocumentPositionParams )( SignatureHelpResponse )
}

interface WorkspaceInterface {
  OneWay:
    didChangeWatchedFiles( DidChangeWatchedFilesParams ),
    didChangeWorkspaceFolders( DidChangeWorkspaceFoldersParams ),
    didChangeConfiguration( DidChangeConfigurationParams )
  RequestResponse:
    symbol( WorkspaceSymbolParams )( undefined ),
    executeCommand( ExecuteCommandParams )( ExecuteCommandResult )
}

interface ServerToClient {
  OneWay:
    publishDiagnostics( PublishDiagnosticParams )
}

interface UtilsInterface {
  RequestResponse:
    getDocument( string )( TextDocument )
  OneWay:
    insertNewDocument( DidOpenTextDocumentParams ),
    updateDocument( DocumentModifications ),
    deleteDocument( DidCloseTextDocumentParams )
}
