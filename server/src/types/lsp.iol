/*
 * Jolie types for the Language Server Protocol
 * see https://microsoft.github.io/language-server-protocol/specification
 */

constants {
	SymbolKind_File = 1,
	SymbolKind_Module = 2,
	SymbolKind_Namespace = 3,
	SymbolKind_Package = 4,
	SymbolKind_Class = 5,
	SymbolKind_Method = 6,
	SymbolKind_Property = 7,
	SymbolKind_Field = 8,
	SymbolKind_Constructor = 9,
	SymbolKind_Enum = 10,
	SymbolKind_Interface = 11,
	SymbolKind_Function = 12,
	SymbolKind_Variable = 13,
	SymbolKind_Constant = 14,
	SymbolKind_String = 15,
	SymbolKind_Number = 16,
	SymbolKind_Boolean = 17,
	SymbolKind_Array = 18,
}

constants {
	CompletionItemKind_Text = 1,
	CompletionItemKind_Method = 2,
	CompletionItemKind_Function = 3,
	CompletionItemKind_Constructor = 4,
	CompletionItemKind_Field = 5,
	CompletionItemKind_Variable = 6,
	CompletionItemKind_Class = 7,
	CompletionItemKind_Interface = 8,
	CompletionItemKind_Module = 9,
	CompletionItemKind_Property = 10,
	CompletionItemKind_Unit = 11,
	CompletionItemKind_Value = 12,
	CompletionItemKind_Enum = 13,
	CompletionItemKind_Keyword = 14,
	CompletionItemKind_Snippet = 15,
	CompletionItemKind_Color = 16,
	CompletionItemKind_File = 17,
	CompletionItemKind_Reference = 18,
	CompletionItemKind_Folder = 19,
	CompletionItemKind_EnumMember = 20,
	CompletionItemKind_Constant = 21,
	CompletionItemKind_Struct = 22,
	CompletionItemKind_Event = 23,
	CompletionItemKind_Operator = 24,
	CompletionItemKind_TypeParameter = 25
}

/*
* @author Eros Fabrici
*/
type InitializeParams {
  processId: int | void
  rootPath?: string | void
  rootUri: DocumentUri | void
  initializationOptions?: undefined
  capabilities: ClientCapabilities
  trace?: string // "off" | "messages" | "verbose"
  workspaceFolders*: WorkspaceFolder | void
}

type WorkspaceFolder {
  uri: string
  name: string
}

type DocumentUri: string


type TextDocumentIdentifier {
  uri: DocumentUri
}

type VersionedTextDocumentIdentifier {
  uri: DocumentUri
  version: int | void
}

type ClientCapabilities {
  workspace?: WorkspaceClientCapabilities
  textDocument?: TextDocumentClientCapabilities
  experimental?: undefined
}

type WorkspaceClientCapabilities {
  applyEdit?: bool
  workspaceEdit? {
    documentChanges?: bool
    resourceOperations*: ResourceOperationKind
    failureHandling?: FailureHandlingKind
  }
  didChangeConfiguration? {
    dynamicRegistration?: bool
  }
  didChangeWatchedFiles? {
    dynamicRegistration?: bool
  }
  symbol? {
    dynamicRegistration?: bool
    symbolKind? {
      valueSet*: SymbolKind
    }
  }
  executeCommand? {
    dynamicRegistration?: bool
  }
  workspaceFolders?: bool
  configuration?: bool
}

type ResourceOperationKind: string //namespace, see official spec
type FailureHandlingKind: string //namespace, see official spec
type MarkupKind: string //namespace, see official spec
type SymbolKind: int //namespace, see official spec
type CompletionItemKind: int // namespace, see official spec
type CodeActionKind: string //namespace, see official spec

type TextDocumentClientCapabilities {
  synchronization? {
    dynamicRegistration?: bool
    willSave?: bool
    willSaveWaitUntil?: bool
    didSave?: bool
  }
  completion? {
    dynamicRegistration?: bool
    completionItem? {
      snippetSupport?: bool
      commitCharactersSupport?: bool
      documentationFormat*: MarkupKind
      deprecatedSupport?: bool
      preselectSupport?: bool
    }
    completionItemKind? {
      valueSet*: CompletionItemKind
    }
    contextSupport?: bool
  }
  hover? {
    dynamicRegistration?: bool
    contentFormat*: MarkupKind
  }
  signatureHelp? {
    dynamicRegistration?: bool
    signatureInformation? {
      documentationFormat*: MarkupKind
      parameterInformation? {
        labelOffsetSupport?: bool
      }
    }
  }
  references? {
    dynamicRegistration?: bool
  }
  documentHighlight? {
    dynamicRegistration?: bool
  }
  documentSymbol? {
    dynamicRegistration?: bool
    symbolKind? {
      valueSet*: SymbolKind
    }
    hierarchicalDocumentSymbolSupport?: bool
  }
  formatting? {
    dynamicRegistration?: bool
  }
  rangeFormatting? {
    dynamicRegistration?: bool
  }
  onTypeFormatting? {
    dynamicRegistration?: bool
  }
  declaration? {
    dynamicRegistration?: bool
    linkSupport?: bool
  }
  definition? {
    dynamicRegistration?: bool
    linkSupport?: bool
  }
  typeDefinition? {
    dynamicRegistration?: bool
    linkSupport?: bool
  }
  implementation? {
    dynamicRegistration?: bool
    linkSupport?: bool
  }
  codeAction? {
    dynamicRegistration?: bool
    codeActionLiteralSupport? {
      codeActionKind {
        valueSet[1,*]: CodeActionKind
      }
    }
  }
  codeLens? {
    dynamicRegistration?: bool
  }
  documentLink? {
    dynamicRegistration?: bool
  }
  rename? {
    dynamicRegistration?: bool
    prepareSupport?: bool
  }
  publishDiagnostics? {
    relatedInformation?: bool
  }
  foldingRange? {
    dynamicRegistration?: bool
    rangeLimit?: int
    lineFoldingOnly?: bool
  }
  colorProvider? {
    dynamicRegistration?: bool
  }
}

type InitializedParams: void

type InitializeResult {
  capabilities: ServerCapabilities
}

type ServerCapabilities {
  textDocumentSync?: TextDocumentSyncOptions | int
  hoverProvider?: bool
  completionProvider?: CompletionOptions
  signatureHelpProvider?: SignatureHelpOptions
  definitionProvider?: bool
  typeDefinitionProvider?: undefined //TODO see LSP specification
  implementationProvider?: undefined //TODO see LSP specification
  referenceProvider?: undefined //TODO see LSP specification
  documentHighlightProvider?: bool
  documentSymbolProvider?: bool
  codeActionProvider?: CodeLensOptions
  documentFormattingProvider?: bool
  documentRangeFormattingProvider?: bool
  documentOnTypeFormattingProvider?: DocumentOnTypeFormattingOptions
  renameProvider?: bool | RenameOptions
  documentLinkProvider?: DocumentLinkOptions
  colorProvider?: undefined //TODO see LSP specification
  foldingRangeProvider?: undefined //TODO see LSP specification
  declarationProvider?: undefined //TODO see LSP specification
  executeCommandProvider?: ExecuteCommandOptions
  workspace? {
    workspaceFolders? {
      supported?: bool
      changeNotifications?: string | bool
    }
  }
  experimental?: undefined
}

type ExecuteCommandOptions {
  /*
   * The commands to be executed on the server
   */
  commands[1,*]: string
}

type DocumentLinkOptions {
  /*
	 * Document links have a resolve provider as well
	 */
	resolveProvider?: bool
}

type RenameOptions {
  /*
   * Renames should be checked and tested before being executed
   */
  prepareProvider?: bool
}

type DocumentOnTypeFormattingOptions {
  /*
   * A character on which formatting should be triggered, like `}`
   */
  firstTriggerCharacter: string
  /*
   * More trigger characters
   */
  moreTriggerCharacter*: string
}

type CodeLensOptions {
  /*
	 * Code lens has a resolve provider as well
	 */
   resolveProvider?: bool
}
type SignatureHelpOptions {
  /*
   * The characters that trigger signature help
   * automatically
   */
  triggerCharacters*: string
}


type ParameterInformation {
  /*
	 * The label of this parameter information.
	 *
	 * Either a string or an inclusive start and exclusive end offsets within its containing
	 * signature label. (see SignatureInformation.label). The offsets are based on a UTF-16
	 * string representation as `Position` and `Range` does.
	 *
	 * *Note*: a label of type string should be a substring of its containing signature label.
	 * Its intended use case is to highlight the parameter label part in the `SignatureInformation.label`.
	 */
  label: string | void { _2: int } //string | [int, int]
  /*
	 * The human-readable doc-comment of this parameter. Will be shown
	 * in the UI but can be omitted.
	 */
  documentation?: string | MarkupContent
}

type SignatureInformation {
  label: string
  documentation?: string | MarkupContent
  parameters*: ParameterInformation
}

type SignatureHelp {
  signatures[1,*]: SignatureInformation
  /*
	 * The active signature. If omitted or the value lies outside the
	 * range of `signatures` the value defaults to zero or is ignored if
	 * `signatures.length === 0`. Whenever possible implementors should
	 * make an active decision about the active signature and shouldn't
	 * rely on a default value.
	 * In future version of the protocol this property might become
	 * mandatory to better express this.
	 */
  activeSignature?: int
  /*
	 * The active parameter of the active signature. If omitted or the value
	 * lies outside the range of `signatures[activeSignature].parameters`
	 * defaults to 0 if the active signature has parameters. If
	 * the active signature has no parameters it is ignored.
	 * In future version of the protocol this property might become
	 * mandatory to better express the active parameter if the
	 * active signature does have any.
	 */
  activeParameter?: int
}

type SignatureHelpResponse: SignatureHelp | void



type CompletionOptions {
  /*
	 * The server provides support to resolve additional
	 * information for a completion item
	 */
   resolveProvider?: bool
	/*
	 * The characters that trigger completion automatically
	 */
   triggerCharacters*: string
}

type TextDocumentSyncOptions {
  /*
	 * Open and close notifications are sent to the server If omitted open close notification should not
	 * be sent
	 */
  openClose?: bool
  /*
	 * Change notifications are sent to the server See TextDocumentSyncKindNone, TextDocumentSyncKindFull
	 * and TextDocumentSyncKindIncremental If omitted it defaults to TextDocumentSyncKindNone
	 */
  change?: int
  /*
	 * If present will save notifications are sent to the server If omitted the notification should not be
	 * sent
	 */
  willSave?: bool
	/*
	 * If present will save wait until requests are sent to the server If omitted the request should not be
	 * sent
	 */
	willSaveWaitUntil?: bool
	/*
	 * If present save notifications are sent to the server If omitted the notification should not be
	 * sent
	 */
  save?: SaveOptions
}

type SaveOptions {
  includeText?: bool
}

type DidOpenTextDocumentParams {
  textDocument: TextDocumentItem
}

type TextDocumentItem {
  /*
	 * The text document's URI
	 */
	uri: DocumentUri
	/*
	 * The text document's language identifier
	 */
	languageId: string
	/*
	 * The version number of this document (it will increase after each
	 * change, including undo/redo)
	 */
	version: int
	/*
	 * The content of the opened text document
	 */
	text: string
}

type DidChangeTextDocumentParams {
  /*
   * The document that did change The version number points
   * to the version after all provided content changes have
   * been applied
   */
  textDocument: VersionedTextDocumentIdentifier
	/*
	 * The actual content changes The content changes describe single state changes
	 * to the document So if there are two content changes c1 and c2 for a document
	 * in state S then c1 move the document to S' and c2 to S''
	 */
	contentChanges[1,*]: TextDocumentContentChangeEvent
}

type TextDocumentContentChangeEvent {
  /*
	 * The range of the document that changed
	 */
	range?: Range
	/*
	 * The length of the range that got replaced
	 */
	rangeLength?: int
	/*
	 * The new text of the range/document
	 */
	text: string
}

type Range {
  start: Position
  end: Position
}

type Position {
  /*
	 * Line position in a document (zero-based)
	 */
	line: int

	/*
	 * Character offset on a line in a document (zero-based) Assuming that the line is
	 * represented as a string, the `character` value represents the gap between the
	 * `character` and `character + 1`
	 *
	 * If the character value is greater than the line length it defaults back to the
	 * line length
	 */
	character: int
}

type WillSaveTextDocumentParams {
  textDocument: TextDocumentIdentifier
  reason: int // 1=Manual, 2=afterDelay, 3=FocusOut
}

type WillSaveWaitUntilResponse: TextEdit | void //TextEdit[1,*]

type DidSaveTextDocumentParams {
  textDocument: VersionedTextDocumentIdentifier
  text?: string
}

type DidCloseTextDocumentParams {
  textDocument: TextDocumentIdentifier
}

type TextEdit {
  range: Range
  newText: string
}

type TextDocumentPositionParams {
  textDocument: TextDocumentIdentifier
  position: Position
}

type CompletionParams {
  textDocument: TextDocumentIdentifier
  position: Position
  context?: CompletionContext
}

type CompletionContext {
  /*
	 * How the completion was triggered
   * CompletionTriggerKind: 1 = Invoked, 2 = TriggerCharacter,
   *                        3 = TriggerForIncompleteCompletions
	 */
	triggerKind: int

	/*
	 * The trigger character (a single character) that has trigger code complete
	 * Is undefined if `triggerKind !== CompletionTriggerKindTriggerCharacter`
	 */
	triggerCharacter?: string
}

type EmptyCompletionList {
    isIncomplete: bool
    items: void
}

type CompletionResult: CompletionList | EmptyCompletionList | void

type CompletionList {
  /*
	 * This list it not complete Further typing should result in recomputing
	 * this list
	 */
	isIncomplete: bool

	/*
	 * The completion items
	 */

  items*: CompletionItem
}

type CompletionItem {
  /*
	 * The label of this completion item By default
	 * also the text that is inserted when selecting
	 * this completion
	 */
	label: string

	/*
	 * The kind of this completion item Based of the kind
	 * an icon is chosen by the editor The standardized set
	 * of available values is defined in `CompletionItemKind`
	 */
	kind?: int

	/*
	 * A human-readable string with additional information
	 * about this item, like type or symbol information
	 */
	detail?: string

	/*
	 * A human-readable string that represents a doc-comment
	 */
	documentation?: string | MarkupContent

	/*
	 * Indicates if this item is deprecated
	 */
	deprecated?: bool

	/*
	 * Select this item when showing
	 *
	 * *Note* that only one completion item can be selected and that the
	 * tool / client decides which item that is The rule is that the *first*
	 * item of those that match best is selected
	 */
	preselect?: bool

	/*
	 * A string that should be used when comparing this item
	 * with other items When `falsy` the label is used
	 */
	sortText?: string

	/*
	 * A string that should be used when filtering a set of
	 * completion items When `falsy` the label is used
	 */
	filterText?: string

	/*
	 * A string that should be inserted into a document when selecting
	 * this completion When `falsy` the label is used
	 *
	 * The `insertText` is subject to interpretation by the client side
	 * Some tools might not take the string literally For example
	 * VS Code when code complete is requested in this example `con<cursor position>`
	 * and a completion item with an `insertText` of `console` is provided it
	 * will only insert `sole` Therefore it is recommended to use `textEdit` instead
	 * since it avoids additional client side interpretation
	 *
	 * @deprecated Use textEdit instead
	 */
	insertText?: string

	/*
	 * The format of the insert text The format applies to both the `insertText` property
	 * and the `newText` property of a provided `textEdit`
	 */
	insertTextFormat?: int //namespace: 1 = plainText, 2 = Snippet

	/*
	 * An edit which is applied to a document when selecting this completion When an edit is provided the value of
	 * `insertText` is ignored
	 *
	 * *Note:* The range of the edit must be a single line range and it must contain the position at which completion
	 * has been requested
	 */
	textEdit?: TextEdit

	/*
	 * An optional array of additional text edits that are applied when
	 * selecting this completion Edits must not overlap (including the same insert position)
	 * with the main edit nor with themselves
	 *
	 * Additional text edits should be used to change text unrelated to the current cursor position
	 * (for example adding an import statement at the top of the file if the completion item will
	 * insert an unqualified type)
	 */
	additionalTextEdits?: TextEdit

	/*
	 * An optional set of characters that when pressed while this completion is active will accept it first and
	 * then type that character *Note* that all commit characters should have `length=1` and that superfluous
	 * characters will be ignored
	 */
	commitCharacters*: string

	/*
	 * An optional command that is executed *after* inserting this completion *Note* that
	 * additional modifications to the current document should be described with the
	 * additionalTextEdits-property
	 */
	command?: Command

	/*
	 * A data entry field that is preserved on a completion item between
	 * a completion and a completion resolve request
	 */
	data?: any
}

/*
 * A `MarkupContent` literal represents a string value which content is interpreted base on its
 * kind flag Currently the protocol supports `plaintext` and `markdown` as markup kinds
 *
 * If the kind is `markdown` then the value can contain fenced code blocks like in GitHub issues
 * See https://helpgithubcom/articles/creating-and-highlighting-code-blocks/#syntax-highlighting
 *
 * Here is an example how such a string can be constructed using JavaScript / TypeScript:
 * ```typescript
 * let markdown: MarkdownContent = {
 *  kind: MarkupKindMarkdown,
 *	value: [
 *		'# Header',
 *		'Some text',
 *		'```typescript',ol INFO: [server.ol] [JSON-RPC debug] Receiving: {"jsonrpc":"2.
 *		'someCode();',
 *		'```'
 *	]join('\n')
 * };
 * ```
 *
 * *Please Note* that clients might sanitize the return markdown A client could decide to
 * remove HTML from the markdown to avoid script execution
 */
type MarkupContent {
  kind: undefined
  value: string
}

type Command {
  title: string
  command: string
  arguments*: undefined
}

type DidChangeWatchedFilesParams {
  changes[1,*]: FileEvent
}

type FileEvent {
  uri: DocumentUri
  /*
   * 1 = created, 2 = Changed, 3 = Deleted
   */
  type: int
}

type DidChangeWorkspaceFoldersParams {
  event: WorkspaceFolderChangeEvent
}

type WorkspaceFolderChangeEvent {
  added[1,*]: WorkspaceFolder
  removed[1,*]: WorkspaceFolder
}

type DidChangeConfigurationParams {
  settings: undefined
}

type WorkspaceSymbolParams {
  query: string
}

type SymbolInformation {
  /*
	 * The name of this symbol
	 */
	name: string
	/*
	 * The kind of this symbol
	 */
	kind: int
	/*
	 * Indicates if this symbol is deprecated
	 */
	deprecated?: bool
	/*
	 * The location of this symbol The location's range is used by a tool
	 * to reveal the location in the editor If the symbol is selected in the
	 * tool the range's start information is used to position the cursor So
	 * the range usually spans more then the actual symbol's name and does
	 * normally include things like visibility modifiers
	 *
	 * The range doesn't have to denote a node range in the sense of a abstract
	 * syntax tree It can therefore not be used to re-construct a hierarchy of
	 * the symbols
	 */
	location: Location

	/*
	 * The name of the symbol containing this symbol This information is for
	 * user interface purposes (eg to render a qualifier in the user interface
	 * if necessary) It can't be used to re-infer a hierarchy for the document
	 * symbols
	 */
	containerName?: string
}

type DocumentSymbolResult {
  _*: SymbolInformation
}

type Location {
  uri: DocumentUri
  range: Range
}

type ExecuteCommandParams {
  command: string
  arguments*: undefined
}

type ExecuteCommandResult: undefined

type Hover {
  contents[1,*]: MarkedString | MarkupContent
  range?: Range
}

type HoverInformations: Hover | void

type MarkedString: string | MarkSt

type MarkSt {
  language: string
  value: string
}

type DiagnosticParams {
  uri: DocumentUri
  diagnostics*: Diagnostic | void
}

type EmptyDiagnosticParams {
  uri: DocumentUri
  diagnostics*: void
}

type PublishDiagnosticParams: DiagnosticParams | EmptyDiagnosticParams

type Diagnostic {
  range: Range
  severity?: int //1=error, 2=warn, 3=info, 4=hint
  code?: int | string
  source?: string
  message: string
  relatedInformation*: DiagnosticRelatedInformation
}

type DiagnosticRelatedInformation {
  location: Location
  message: string
}

type DocumentSymbolParams {
  textDocument: TextDocumentIdentifier
}

type Snippet: string {
  prefix: string
  body: string
}

type TextDocument {
  uri: string
  lines*: string
  source: string
  version: int
  jolieProgram?: undefined
}

type DocumentModifications {
  version: int
  uri: string
  text: string
}
