include "console.iol"
include "string_utils.iol"
include "runtime.iol"
include "file.iol"

include "../interfaces/lsp.iol"
include "inspector.iol"

/*
 * The main aim of this service is to keep saved
 * in global.textDocument all open documents
 * and keep them updated. The type of global.textDocument
 * is TextDocument and it is defined in types/lsp.iol
 */

execution { sequential }

constants {
  INTEGER_MAX_VALUE = 2147483647
}

inputPort Utils {
  Location: "local://Utils"
  Interfaces: UtilsInterface
}

outputPort Client {
  location: "local://Client"
  Interfaces: ServerToClient
}

interface InspectionUtilsIface {
  RequestResponse:
    inspect
  OneWay:
    sendEmptyDiagnostics
}

service InspectionUtils {

  Interfaces: InspectionUtilsIface

  init {
    println@Console( "InspectionUtils Service started" )()
  }

  main {
    [ inspect( documentData )( inspectionResult ) {
      println@Console( "Inspecting..." )(  )
      scope( inspection ) {
        inspectionResult.saveProgram = true
        install( default =>
          stderr = inspection.(inspection.default)
          stderr.regex =  "\\s*(.+):\\s*(\\d+):\\s*(error|warning)\\s*:\\s*(.+)"
          find@StringUtils( stderr )( matchRes )
          // //getting the uri of the document to be checked
          //have to do this because the inspector, when returning an error,
          //returns an uri that looks the following:
          // /home/eferos93/.atom/packages/Jolie-ide-atom/server/file:/home/eferos93/.atom/packages/Jolie-ide-atom/server/utils.ol
          //same was with jolie --check
          if ( !(matchRes.group[1] instanceof string) ) {
            matchRes.group[1] = ""
          }
          indexOf@StringUtils( matchRes.group[1] {
            word = "file:"
          } )( indexOfRes )
          
          if ( indexOfRes > -1 ) {
            substring@StringUtils( matchRes.group[1] {
              begin = indexOfRes + 5
            } )( documentUri ) //line
          } else {
            replaceAll@StringUtils( matchRes.group[1] {
              regex = "\\\\"
              replacement = "/"
            } )( documentUri )
            // documentUri = "///" + fileName
          }
          
          //line
          l = int( matchRes.group[2] )
          //severity
          sev -> matchRes.group[3]
          //TODO always return error, never happend to get a warning
          //but this a problem of the jolie parser
          if ( sev == "error" ) {
            s = 1
          } else {
            s = 1
          }

          diagnosticParams << {
            uri = "file:" + documentUri
            diagnostics << {
              range << {
                start << {
                  line = l-1
                  character = 1
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
          inspectionResult.saveProgram = false
          inspectionResult.diagnostics << diagnosticParams
        )

        // TODO : fix these:
        // - remove the directories of this LSP
        // - add the directory of the open file.
        getenv@Runtime( "JOLIE_HOME" )( jHome )
        getFileSeparator@File()( fs )
        getParentPath@File( documentData.uri )( documentPath )
        regexRequest = documentData.uri
	      regexRequest.regex =  "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"
        find@StringUtils( regexRequest)( regexResponse )

        //Spaces in file URIs are encoded with %20 in some systems
        replaceAll@StringUtils( regexResponse.group[5] {
          regex = "%20" 
          replacement = " "
        } )( inspectionReq.filename )

        inspectionReq << {
          source = documentData.text
          includePaths[0] = jHome + fs + "include"
        }

        //Spaces in file URIs are encoded with %20 in some systems
        replaceAll@StringUtils( documentPath {
          regex = "%20"
          replacement = " "
        } )( inspectionReq.includePaths[1] )

        inspectPorts@Inspector( inspectionReq )( inspectionResult.result )
      }
    }]

    [ sendEmptyDiagnostics( uri ) ] {
        println@Console( "Sending empty diagnostics" )(  )
        diagnosticParams << {
          //uri = inspectionResult.uri
          uri = uri
          diagnostics = void
        }
        publishDiagnostics@Client( diagnosticParams )
      }
  }
}

init {
  println@Console( "Utils Service started" )(  )
}

main {
  [ insertNewDocument( newDoc ) ] {
      docText -> newDoc.textDocument.text
      uri -> newDoc.textDocument.uri
      version -> newDoc.textDocument.version
      splitReq = docText
      splitReq.regex = "\n"
      split@StringUtils( splitReq )( splitRes )
      for ( line in splitRes.result ) {
        doc.lines[#doc.lines] = line
      }
      //inspect
      inspect@InspectionUtils( {
        uri = uri
        text = docText
      } )( inspectionResult )

      //sendDiagnostics
      if( inspectionResult.saveProgram ) {
        sendEmptyDiagnostics@InspectionUtils( uri )
        doc.jolieProgram << inspectionResult.result
      }

      doc << {
        uri = uri
        source = docText
        version = version
      }

      // TODO: use a dictionary with URIs as keys instead of an array
      global.textDocument[#global.textDocument] << doc
  }

  [ updateDocument( txtDocModifications ) ] {
      docText -> txtDocModifications.text
      uri -> txtDocModifications.uri
      newVersion -> txtDocModifications.version
      docsSaved -> global.textDocument
      found = false
      for ( i = 0, i < #docsSaved && !found, i++ ) {
        if ( docsSaved[i].uri == uri ) {
          found = true
          indexDoc = i
        }
      }
      //TODO is found == false, throw ex (should never happen though)
      if ( found && docsSaved[indexDoc].version < newVersion ) {
        splitReq = docText
        splitReq.regex = "\n"
        split@StringUtils( splitReq )( splitRes )
        for ( line in splitRes.result ) {
          doc.lines[#doc.lines] = line
        }

        //inspect
        inspect@InspectionUtils( {
          uri = uri
          text = docText
        } )( inspectionResult )

        //sendDiagnostics
        if( inspectionResult.saveProgram ) {
          sendEmptyDiagnostics@InspectionUtils( uri )
          doc.jolieProgram << inspectionResult.result
        }
        doc << {
          source = docText
          version = newVersion
        }

        docsSaved[indexDoc] << doc
      }// else {
        //inspect

        //sendDiagnostics
        //if( inspectionResult.saveProgram ) {
        //  sendEmptyDiagnostics@InspectionUtils()
        //  doc.jolieProgram << inspectionResult.result
        //}
        // doc.jolie << inspectionResult
      //}
  }

  [ deleteDocument( txtDocParams ) ] {
      uri -> txtDocParams.textDocument.uri
      docsSaved -> global.textDocument
      keepRunning = true
      for ( i = 0, i < #docsSaved && keepRunning, i++ ) {
        if ( uri == docsSaved[i].uri ) {
          undef( docsSaved[i] )
          keepRunning = false
        }
      }
  }

  [ getDocument( uri )( txtDocument ) {
      docsSaved -> global.textDocument
      found = false
      for ( i = 0, i < #docsSaved && !found, i++ ) {
        if ( docsSaved[i].uri == uri ) {
          txtDocument << docsSaved[i]
          found = true
        }
      }

      if ( !found ) {
        //TODO: if found == false throw exception
        println@Console( "doc not found!!!" )()
      }
  } ]
}
