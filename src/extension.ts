import * as path from 'path'
import * as net from 'net'
import { window, workspace, ExtensionContext, Task, tasks, ShellExecution, OutputChannel, Uri } from 'vscode'
import * as cp from 'child_process'
import { LanguageClient, LanguageClientOptions, StreamInfo } from 'vscode-languageclient'
import * as semver from 'semver'
import * as execa from 'execa'
import * as vscode from 'vscode'

let client: LanguageClient
let proc: cp.ChildProcess
let logger: OutputChannel

const versionRequirement = ">=1.10.1"
const IsWindows = ( process.platform === "win32" )

function getConfigValue( value: string ): any {
	return workspace.getConfiguration().get( value )
}

function createRunTask( title: string ): Task {
	let file = window.activeTextEditor.document.fileName;
	let dir = path.dirname( file )
	return new Task( 
		{ type: "run", task: "runJolie" },
		title,
		"Jolie", 
		new ShellExecution( `jolie "${file}"`, { cwd : dir } ), 
		[]
	)
}

async function checkRequiredJolieVersion():Promise<void> {
	try {
		const p = await execa('jolie', ['--version'])
		const stderr = p.stderr
		const result = stderr.match(/Jolie\s+(\d+\.\d+\.\d+).+/)
		if (result.length > 1) {
			const jolieVersion = result[1]
			if( !semver.satisfies(jolieVersion, versionRequirement) ) {
				window.showErrorMessage(`This extension requires Jolie version ${versionRequirement}, whereas your version is ${jolieVersion}. Some features may not work correctly. Please consider updating your Jolie installation.`)
			}
		} else {
			window.showErrorMessage(`Could not detect the version of the Jolie interpreter. Output of \"jolie --version\": ${stderr}`)
		}
	} catch(err) {
		window.showErrorMessage('Could not start the Jolie interpreter. Please check that the jolie executable is installed.')
	}
}

function registerTasks() {
	tasks.registerTaskProvider( "run", {
		provideTasks: () => {
			return [ createRunTask( "Run current Jolie program" ) ];
		},
		resolveTask( task : Task ): Task | undefined {
			return task
		}
	})
}

function log( message: string ) {
	if( getConfigValue( 'jolie.languageServer.showDebugMessages' ) ){
		logger.appendLine( message )
	}
}

export async function activate(context: ExtensionContext) {
	await checkRequiredJolieVersion()
	registerTasks()
	
	logger = window.createOutputChannel( 'Jolie LSP Client' )
	const tcpPort: number = getConfigValue( 'jolie.languageServer.tcpPort' )

	log( "Activating Jolie Language Server" )
	
	const serverOptions = () => new Promise<StreamInfo>( (resolve, reject) => {
		const serverPath = vscode.extensions.getExtension("jolie.vscode-jolie").extensionPath
		var command: string
		var args: string[]
		
		if(IsWindows){
			command = 'cmd.exe'
			args = ['/C', 'npx', '--yes', '--package', '@jolie/languageserver', 'joliels', `${tcpPort}`]
		} else {
			command = 'npx'
			args = ['--package', '@jolie/languageserver', 'joliels', `${tcpPort}`]
		}

		log(`starting "${command} ${args.join(' ')}"`)
		proc = cp.spawn(command, args)

		proc.on("error", (err)=>{
			log(`error: ${String(err)}`)
		})

		proc.stdout.on('data', (out) => {
			const message = String(out)
			if ( message.includes( "Jolie Language Server started" ) ) {
				//if the jolie process has started, we connect the client to the socket and resolve the childProcess
				const socket = net.createConnection( { port : tcpPort, host:'localhost' } )
				resolve({ reader: socket, writer: socket })
			}
			log(`Jolie says: ${message}`)
		})
		proc.stderr.on('data', (out) => {
			let s = String( out )
			if( s.includes( "service initialisation failed" ) ){
				window.showErrorMessage( s )
			}
			if( s.includes( "Address already in use" ) ){
				window.showErrorMessage( s )
				window.showInformationMessage( "Please check that the TCP port " + tcpPort + " of the local machine is free. " + 
				"Alternatively, you can change the TCP port number under the Jolie Language Support extension configuration. " +
				"After the change, remember to reboot your editor." )
			}
			log( s )
		})
	})

	const clientOptions: LanguageClientOptions = {
		documentSelector: [{ scheme: 'file', language: 'jolie' }, { scheme: 'untitled', language: 'jolie' }],
		synchronize: {
			// configurationSection: 'jolie',
			fileEvents: workspace.createFileSystemWatcher('**/*.{ol,iol}')
		},
		uriConverters: {
			// See https://github.com/Microsoft/vscode-languageserver-node/issues/105
			code2Protocol: uri =>
				IsWindows ? uri.toString().replace('%3A', ':') : uri.toString(),
			protocol2Code: str => Uri.parse(str),
		}
	}

	client = new LanguageClient(
		'vscode-jolie',
		'Jolie Language Server',
		serverOptions,
		clientOptions
	)

	client.start()
}

export async function deactivate(): Promise<void> | undefined {
	if ( !client ) {
		if ( proc ) {
			proc.kill( 'SIGINT' )
		}
		return undefined	
	}
	return client.stop().then( () => {
		if ( proc ) {
			proc.kill( 'SIGINT' )
		}
	} )
}