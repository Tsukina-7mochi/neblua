# NebLua

NebLua is a tiny zero-dependency bundler for Lua. Lua 5.3 and 5.4 are supported.

## Installation

Download single source file from [Releases](https://github.com/Tsukina-7mochi/neblua/releases)

```sh
# download neblua
$ curl https://github.com/Tsukina-7mochi/neblua/releases/latest/download/neblua.lua

# or neblua CLI
$ curl https://github.com/Tsukina-7mochi/neblua/releases/latest/download/neblua-cli.lua
```

## Usage

### In source file

`require`-ed modules are resolevd in `package.path` and added to bundle automatically.

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

When using `dofile` or `loadfile`, you have to add it to bundle manually (see below).

Use `requireText` to add a resource to the bundle as a text.

```lua
local requireText = require("neblua").requireText
local resource = requireText("module1")
print(resource)
```

### CLI

```
$ lua neblua-cli [options] [files]
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
| `verbose`        | `boolean \| nil`  | Enable verbose output for debug. Defaults to `false.                                                                                      |

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
