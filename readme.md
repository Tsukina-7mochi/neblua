# NebLua

NebLua is a tiny zero-dependency bundler for Lua. Lua 5.3 supported but it may work for Lua 5.4.

## Features

- Bundle `require`, `loadfile` and `dofile` functions
- Text import by `requireText`

## Installation

Download single source file from [Releases](https://github.com/Tsukina-7mochi/neblua/releases)

## Usage

### Program (recommended)

This is a part of configuration of NebLua's self-build. See `/example`, `./bundleSelf.lua` and `/test/bundle/bundle.test.lua`

```lua
local bundle = require("src.neblua").bundle

bundle {
    entry = "src.main",
    output = "./dist/main.bundle.lua",
    files = {
        "./src/main.lua",
        -- manually add files (for sub-effects)
        "./src/foo.lua",
        -- specifying types
        { path: "./src/bar.lua", type: "lua" },
        { path: "./src/some.txt", type: "text" },
    }
}
```

#### Bundle Options

|    key    |             value              |
| --------- | ------------------------------ |
| `rootDir` | root directory of source files |
| `entry`   | entry module name              |
| `output`  | output file name               |
| `files`   | source files                   |
| `verbose` | enable verbose mode            |

### CLI

```
$ lua neblua-cli [options] [files]
```

| options | value | function |
|---|---|---|
| `-e`, `--entry` | module name | set entry point |
| `-o`, `--output` | file name | set output file name |
| `--verbose` | none | enable verbose mode |
| `-v`, `--version` | none | print version |

## Plans

- [x] support `require`
- [x] support `loadfile`
- [x] support `dofile`
- [x] error output override
- [x] string require
- [ ] automatically add required files
- [ ] minify
- [ ] tree shaking
