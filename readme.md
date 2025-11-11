<div align="center">
<h1>NebLua</h1>

<div>A tiny zero-dependency bundler for Lua</div>
<div>Supports Lua 5.3 and 5.4</div>

</div>

## Installation

Download single source file from [Releases](https://github.com/Tsukina-7mochi/neblua/releases)

```sh
# download neblua
$ curl -fsSL https://github.com/Tsukina-7mochi/neblua/releases/latest/download/neblua.lua > neblua.lua

# or neblua CLI
$ curl -fsSL https://github.com/Tsukina-7mochi/neblua/releases/latest/download/neblua-cli.lua > neblua-cli.lua
```

## Quick Start

Basically, you don't have to do special thing in your source file. NebLua automatically includes `require`-ed modules to bundle. When using `dofile` or `loadfile`, you have to add it to bundle manually (see the Usage section).

```lua
-- module1.lua
return {
  greeting = function()
    print("module 1")
  end
}

-- main.lua
local module1 = require("module1")
module1.greeting()
```

Use `requireText` to add a resource to bundle as a string literal.

```lua
local requireText = require("neblua").requireText

-- line below is replaced to string literal assignment in generated file.
local resource = requireText("module1")
print(resource)
```

Then, run CLI to bundle source files into a file.

```
$ lua neblua-cli -e main -o ./dist/script.lua
```

## Usage

### CLI

```
$ lua neblua-cli [options] [additional files]
```

See `lua neblua-cli --help` for details.

### Lua

This is a part of configuration of NebLua's self-build. See `/example` and `/test/bundle/bundle.test.lua`

```lua
local bundle = require("src.neblua").bundle

bundle {
    entry = "src.main",
    output = "./dist/main.bundle.lua",
    include = {
        -- manually link files (useful when using dofile or loadfile)
        "./src/foo.lua",

        -- specifying types
        { path: "./src/bar.lua", type: "lua" },
        { path: "./src/some.txt", type: "text" },
    },
    exclude = {},      --Optional
    external = {},     --Optional
    rootDir = nil,     --Optional
    verbose = true,    --Optional
    header = "",       -- Optional
    preInitCode = "",  -- Optional
    postInitCode = "", -- Optional
    preRunCode = "",   -- Optional
    postRunCode = ""   -- Optional
}
```

## API

### neblua.bundle

```
neblua.bundle(options: BuildOptions)
```

Bundles input files into one file.

#### BuildOptions

|       key        |       type        |             value                                                                                                                         |
| ---------------- | ----------------- |  ---------------------------------------------------------------------------------------------------------------------------------------- |
| `rootDir`        | `string \| nil`   | Root directory used to path resolution. Applied after module resolution with `package.path`. Defaults to `./`.                            |
| `entry`          | `string`          | Entry module name. Required.                                                                                                              |
| `include`        | `File[] \| nil`   | Files added to bundle. `File` is `string \| { path: string, type: string }`. `path` must be file path, not module name. Defaults to `{}`. |
| `output`         | `string`          | Output file name. Required.                                                                                                               |
| `exclude`        | `string[] \| nil` | Excluded files used in path resolution. Specified in patterns. Defaults to `{}`.                                                          |
| `external`       | `string[] \| nil` | External modules and files. These modules/files are referenced in runtime. Defaults to `{}`.                                              |
| `fallbackStderr` | `string[] \| nil` | Use of stdout instead of stderr to print error in bundled file. Defaults to `false`.                                                      |
| `verbose`        | `boolean \| nil`  | Enable verbose output for debug. Defaults to `false`.                                                                                     |
| `header`         | `string \| nil`   | Additional text included in header of bundled file. Defaults to `""`.                                                                     |
| `preInitCode`    | `string \| nil`   | Text inserted before initialization of bundled file. Defaults to `""`.                                                                    |
| `postInitCode`   | `string \| nil`   | Text inserted after initialization of bundled file. Defaults to `""`.                                                                     |
| `preRunCode`     | `string \| nil`   | Text inserted before execution of entry point in bundled file. Defaults to `""`.                                                          |
| `postRunCode`    | `string \| nil`   | Text inserted after execution of entry point in bundled file. Executed whether entry module returns error. Defaults to `""`.              |
### neblua.requireText

```
neblua.requireText(path: string): string
```

Requires module as text file. Returns text content of the given file.

### neblua.appInfo

```
neblua.appInfo
```

|    key    |   type   |         value         |
| --------- | -------- | --------------------- |
| `name`    | `string` | the value `"neblua"`  |
| `version` | `string` | the version of neblua |
