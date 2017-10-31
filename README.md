# rbxpacker
rbxpacker generates installation scripts for Roblox Lua libraries. Users can install library packages created by rbxpacker using the Roblox Studio 'Run Script' menu.

It's intended to serve as a holdover until a better library packaging solution is developed.

## Installation
rbxpacker builds with the latest version of Rust, which is currently version 1.21.0.

## Usage
rbxpacker outputs the resulting installation script to stdout. To save it, you can write it to a file:

```sh
rbxpacker INPUT > installer.lua
```

## License
rbxpacker is available under the MIT license. See [LICENSE.md](LICENSE.md) for details.