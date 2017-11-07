# rbxpacker
rbxpacker generates installation scripts for Roblox Lua libraries. Users can install library packages created by rbxpacker using the Roblox Studio 'Run Script' menu.

It's intended to serve as a holdover until a better library packaging solution is developed.

## Installation
rbxpacker builds with the latest version of Rust, currently version 1.21.0.

On Windows, you can check [the GitHub releases page](https://github.com/LPGhatguy/rbxpacker/releases) to download the latest version of rbxpacker.

Otherwise, you can install rbxpacker with Cargo:
```bash
cargo install rbxpacker
```

## Usage
rbxpacker outputs the resulting installation script to stdout. To save it, you can write it to a file:

```sh
rbxpacker INPUT > installer.lua
```

For more options, check out `rbxpacker --help`.

## License
rbxpacker is available under the MIT license. See [LICENSE.md](LICENSE.md) for details.