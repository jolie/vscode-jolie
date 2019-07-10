include "console.iol"
include "exec.iol"
include "string_utils.iol"

include "../interfaces/lsp.iol"

constants {
  INTEGER_MAX_VALUE = 2147483647
}

execution{ concurrent }

inputPort SyntaxChecker {
  Location: "local://SyntaxChecker"
  Interfaces: SyntaxCheckerInterface
}

outputPort Client {
  location: "local://Client"
  Interfaces: ServerToClient
}

main {
  [ syntaxCheck( document ) ] {
    println@Console( "syntaxChecker started for " + document.path )()

    cmd = "jolie"
    cmd.args[0] = "--check"
    cmd.args[1] = document.path
    cmd.stdOutConsoleEnable = true
    cmd.waitFor = 1
    exec@Exec( cmd )( result )
    if ( result.exitCode == 0 ) {
      diagnosticParams << {
        uri = document.path
        diagnostics = void
      }
      publishDiagnostics@Client( diagnosticParams )
      println@Console( "SyntaxChecker ended: no errors" )()
    } else {
      //if we have an error we apply a regex to get error message and line
      messageRegex = "\\s*(.+):\\s*(\\d+):\\s*(error|warning)\\s*:\\s*(.+)"
      matchReq = result.stderr
      println@Console( matchReq )(  )
      matchReq.regex = messageRegex
      find@StringUtils( matchReq )( matchRes )
      //getting the uri of the document to be checked
      //have to do this because the inspector, when returning an error,
      //returns an uri that looks the following:
      // /home/eferos93/.atom/packages/Jolie-ide-atom/server/file:/home/eferos93/.atom/packages/Jolie-ide-atom/server/utils.ol
      //same was with jolie --check
      indexOfReq = matchRes.group[1]
      indexOfReq.word = "file:"
      indexOf@StringUtils( indexOfReq )( indexOfRes )
      subStrReq = matchRes.group[1]
      subStrReq.begin = indexOfRes + 5 //length of "file:"
      length@StringUtils( matchRes.group[1] )( subStrReq.end )
      substring@StringUtils( subStrReq )( documentUri )
      //line
      l = int( matchRes.group[2] )
      //severity
      sev -> matchRes.group[3]

      if ( sev == "error" ) {
        s = 1
      }

      diagnosticParams << {
        uri = documentUri
        diagnostics << {
          range << {
            start << {
              line = l-1
              character = INTEGER_MAX_VALUE
            }
            end << {
              line = l-1
              character = INTEGER_MAX_VALUE
            }
          }
          severity = s
          source = "jolie"
          message = matchRes.group[4]
        }
      }
      publishDiagnostics@Client( diagnosticParams )
    }
  }
}
