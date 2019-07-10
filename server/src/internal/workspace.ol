include "console.iol"
include "string_utils.iol"
include "runtime.iol"
include "exec.iol"

include "../interfaces/lsp.iol"

execution { concurrent }

inputPort WorkspaceInput {
  Location: "local"
  Interfaces: WorkspaceInterface
}
 
init {
  println@Console( "workspace running" )()
}

main {
  [ didChangeWatchedFiles( notification ) ] {
    println@Console( "Received didChangedWatchedFiles" )()
  }

  [ didChangeWorkspaceFolders( notification ) ] {
    newFolders -> notification.event.added
    removedFolders -> notification.event.removed
    for(i = 0, i<#newFolders, i++) {
      global.workspace.folders[#global.workspace.folders+(i+1)] = newFolders[i]
    }
    for(i = 0, i<#removedFolders, i++) {
      for(j = 0, i<#global.workspace.folders, j++) {
        if(global.workspace.folders[j] == removedFolders[i]) {
          undef( global.workspace.folders[j] )
        }
      }
    }
  }

  [ didChangeConfiguration( notification ) ] {
      valueToPrettyString@StringUtils( notification )(res)
      println@Console("didChangeConfiguration received " + res)()
  }

  [ executeCommand( commandParams )( commandResult ) {
      cmd -> commandParams.commandParams
      args -> commandParams.arguments
      command = cmd
      command.args = args
      exec@Exec( command )( commandResult )
  }]
}
