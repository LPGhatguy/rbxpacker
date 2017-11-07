# rbxpacker Changelog

## Current master
- Added support for multiple `<INPUT>` parameters.
- Using a file name now works, with some caveats:
	- When adding a directory, the path to the directory will be stripped
	- When adding a file, the full path to the file will be preserved
	- `rbxpacker --folder FOO lib LICENSE.md` will create a `FOO` folder with the contents of `lib` and a `StringValue` named `LICENSE`.

## 1.1.0
- Added support for collapsing `init.lua` files. A folder on the file system containing an `init.lua` file will turn into a `ModuleScript` containing the folder's items when installed.
	- This can be disabled using `--no_collapse`

## 1.0.0
- Initial release