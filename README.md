# Jolie extension for Visual Studio Code

Support for the [Jolie programming language](https://jolie-lang.org) inside of Visual Studio Code. Enjoy!

## Features

- Syntax highlighting.

- Completion:

![Completion](images/feature-completion.gif)

- Hover:

![Hover](images/feature-hover.gif)

## Requirements

- [Jolie](https://jolie-lang.org) 1.8.1 or above.

## Extension Settings

None for now.

## Known Issues

- Requires the environment variable `JOLIE_HOME` to be set correctly.

## Release Notes

### 1.1.0

- Created extensions configuration parameters:
  - `Server Port`: the TCP port of the Jolie LSP Server. Default is `9123`.
  - `Show Debug Messages`: if set to true, show debug information in the output channel `Jolie LSP Client`. The Output view is toggable under View -> Output. The channel selection is via the dropdown menu on the left.
- The Jolie LSP Server process is closed when also the client closes.
- Error message in case the Jolie LSP Server cannot start properly (includes information on how to solve the problem via extension configurations).

### 1.0.0

- Detection of the necessary Jolie version.
- Notify the user if the Jolie executable cannot be found.

### 0.9.3

First release.