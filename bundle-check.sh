#!/bin/bash
cd "$(dirname "$0")"

LUA="${LUA:-lua}"

mkdir -p ./dist

# bundle neblua and neblua-cli
$LUA ./src/cli.lua -e src.neblua -o ./dist/neblua.lua ./src/neblua.lua
$LUA ./src/cli.lua -e src.cli -o ./dist/neblua-cli.lua ./src/cli.lua

# self-bundle and check diff of output
$LUA ./dist/neblua-cli.lua -e src.cli -o ./dist/temp.lua ./src/cli.lua
diff ./dist/neblua-cli.lua ./dist/temp.lua
rm ./dist/temp.lua
