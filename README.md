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

> This Jolie version is only available through git for now. A new release will appear in the next few weeks.

## Extension Settings

None for now.

## Known Issues

- The Jolie Language Server tcp port is statically fixed as 9123. This should be a configurable setting at least.
- Requires the environment variable `JOLIE_HOME` to be set correctly.

## Release Notes

### 0.9.3

First release.

### 1.0.0

- Detection of the necessary Jolie version.
- Notify the user if the Jolie executable cannot be found.