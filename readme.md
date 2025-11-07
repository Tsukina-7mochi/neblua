# NebLua

NebLua is a tiny zero-dependency bundler for Lua. Lua 5.3 and 5.4 supported.

## Features

- Bundle `require`, `loadfile` and `dofile` functions
- Text import with `requireText`

## Installation

Download single source file from [Releases](https://github.com/Tsukina-7mochi/neblua/releases)

## Usage

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
    exclude = {},    --Optional
    external = {},   --Optional
    rootDir = nil,   --Optional
    verbose = true,  --Optional
}
```

## API

### neblua.bundle

```
neblua.bundle(options: BuildOptions)
```

Bundles input files into one file.

#### BuildOptions

|       key        |       type        |             value                                             |
| ---------------- | ----------------- |  ------------------------------------------------------------ |
| `rootDir`        | `string \| nil`   | root directory of source files                                |
| `entry`          | `string`          | entry module name                                             |
| `include`        | `File[] |\ nil`   | source files (where `File` is `string \| { path: string, type: string }`) |
| `output`         | `string`          | output file name                                              |
| `verbose`        | `boolean \| nil`  | enable verbose output                                         |
| `exclude`        | `string[] \| nil` | excludes files from bundle with patterns                      |
| `external`       | `string[] \| nil` | mark a module or file as external to prevent resolution error |
| `fallbackStderr` | `string[] \| nil` | enable use of stdout instead of stderr                        |

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
