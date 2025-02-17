# NebLua

NebLua is a tiny zero-dependency bundler for Lua. Lua 5.4 supported but it may work for Lua 5.3.

## Features

- Bundle `require`, `loadfile` and `dofile` functions
- Text import with `requireText`

## Installation

Download single source file from [Releases](https://github.com/Tsukina-7mochi/neblua/releases)

## Usage

### Lua

This is a part of configuration of NebLua's self-build. See `/example` and `/test/bundle/bundle.test.lua`

```lua
local bundle = require("src.neblua").bundle

bundle {
    entry = "src.main",
    output = "./dist/main.bundle.lua",
    include = {
        "./src/main.lua",

        -- manually add files (for sub-effects)
        "./src/foo.lua",
    exclude = {},    --Optional
    rootDir = nil,   --Optional

        -- specifying types
        { path: "./src/bar.lua", type: "lua" },
        { path: "./src/some.txt", type: "text" },
    },
    verbose = true,  --Optional
}
```

### CLI

```
$ lua neblua-cli [options] [files]
```

|       options       |    value    |                function                |
| ------------------- | ----------- | -------------------------------------- |
| `-e`, `--entry`     | module name | set entry point                        |
| `-o`, `--output`    | file name   | set output file name                   |
| `--verbose`         | none        | enable verbose mode                    |
| `-v`, `--version`   | none        | print version                          |
| `--exclude`         | none        | excluded file patterns from bundle     |
| `--fallback-stderr` | none        | enable use of stdout instead of stderr |

## API

### neblua.bundle

```
neblua.bundle(options: BuildOptions)
```

Bundles input files into one file.

#### BuildOptions

|       key        |       type        |             value                        |
| ---------------- | ----------------- |  --------------------------------------- |
| `rootDir`        | `string \| nil`   | root directory of source files           |
| `entry`          | `string`          | entry module name                        |
| `include`        | `File[]`          | source files (where `File` is `string \| { path: string, type: string }`) |
| `output`         | `string`          | output file name                         |
| `verbose`        | `boolean \| nil`  | enable verbose output                    |
| `exclude`        | `string[] \| nil` | excludes files from bundle with patterns |
| `fallbackStderr` | `string[] \| nil` | enable use of stdout instead of stderr   |

### neblua.requireText

```
neblua.requireText(path: string): string
```

Requires module as text file. Returns text content of the given file.

#### Example

```lua
local requireText = require("neblua").requireText

-- Text content is bundled
local version = requireText("./version.txt")
print(version)
```

### neblua.appInfo

```
neblua.appInfo
```

|    key    |   type   |         value         |
| --------- | -------- | --------------------- |
| `name`    | `string` | the value `"neblua"`  |
| `version` | `string` | the version of neblua |

## Plans

- [x] support `require`
- [x] support `loadfile`
- [x] support `dofile`
- [x] error output override
- [x] string require
- [x] (partially) automatically add required files
- [ ] minify
- [ ] tree shaking
