/*
 * Main Service that communicates directly with the client and provides the basic
 * operations
  */
execution { sequential }

include "internal/deployment.iol"

include "console.iol"
include "string_utils.iol"
include "runtime.iol"

init {
  Client.location -> global.clientLocation
  println@Console( "Jolie Language Server started" )()
  global.receivedShutdownReq = false
  //we want full document sync as we build the ProgramInspector for each
  //time we modify the document
}

main {
    [ initialize( initializeParams )( serverCapabilities ) {
      println@Console( "Initialize message received" )()
      global.processId = initializeParams.processId
      global.rootUri = initializeParams.rootUri
      global.clientCapabilities << initializeParams.capabilities
      //for full serverCapabilities spec, see
      // https://microsoft.github.io/language-server-protocol/specification
      // and types.iol
      serverCapabilities.capabilities << {
        textDocumentSync = 1 //0 = none, 1 = full, 2 = incremental
        completionProvider << {
          resolveProvider = false
          triggerCharacters[0] = "@"
        }
        //signatureHelpProvider.triggerCharacters[0] = "("
        definitionProvider = false
        hoverProvider = true
        documentSymbolProvider = false
        referenceProvider = false
        //experimental;
      }
    } ]

    [ initialized( initializedParams ) ] {
      println@Console( "Initialization done " )()
    }

    [ shutdown( req )( res ) {
        println@Console( "Shutdown request received..." )()
        global.receivedShutdownReq = true
    }]

    [ onExit( notification ) ] {
      if( !global.receivedShutdownReq ) {
        println@Console( "Did not receive the shutdown request, exiting anyway..." )()
      }
      println@Console( "Exiting Jolie Language server..." )()
      exit
    }
    //received from syntax_checker.ol
    [ publishDiagnostics( diagnosticParams ) ] {
      println@Console( "publishing diagnostics for " + diagnosticParams.uri )()
      publishDiagnostics@Client( diagnosticParams )
    }

    [ cancelRequest( cancelReq ) ] {
        println@Console( "cancelRequest received ID: " + cancelReq.id )()
        //TODO
    }
}
