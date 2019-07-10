

import * as path from 'path'
import * as net from 'net'
import { commands, window, workspace, ExtensionContext } from 'vscode'
import * as cp from 'child_process'
import { LanguageClient, LanguageClientOptions, StreamInfo } from 'vscode-languageclient'

let client: LanguageClient

export function activate(context: ExtensionContext) {
	console.log("Activating Jolie Language Server")
	
	const serverOptions = () => new Promise<StreamInfo>( (resolve, reject) => {
		const serverPath = context.asAbsolutePath(path.join('server', 'src'))
		const tcpPort = 9123
		const command = 'jolie'
		const olFile = 'main.ol'
		const args = ['-C', `Location_JolieLS=\"socket://localhost:${tcpPort}\"`, olFile]
		// const args = ['-C', `Location_JolieLS=\"socket://localhost:${tcpPort}\"`, '-C', 'Debug=true', olFile]
		// const args = ['-C', `Location_JolieLS=\"socket://localhost:${tcpPort}\"`, '--trace', olFile]
		console.log(`starting "${command} ${args.join(' ')}"`)
		const proc = cp.spawn(command, args, { cwd: serverPath })

		proc.stdout.on('data', (out) => {
			const message = String(out)
			if ( message.includes( "Jolie Language Server started" ) ) {
				//if the jolie process has started, we connect the client to the socket and resolve the childProcess
				const socket = net.createConnection({ port : tcpPort, host:'localhost' })
				resolve({ reader: socket, writer: socket })
			}
			console.log(`Jolie says: ${message}`)
		})
		proc.stderr.on('data', (out) => {
			console.log(String(out))
		})
	})

	const clientOptions: LanguageClientOptions = {
		documentSelector: [{ scheme: 'file', language: 'jolie' }, { scheme: 'untitled', language: 'jolie' }],
		synchronize: {
			// configurationSection: 'jolie',
			fileEvents: workspace.createFileSystemWatcher('**/*.{ol,iol}')
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

export function deactivate(): Thenable<void> | undefined {
	if (!client) {
		return undefined
	}
	return client.stop()
}