LUA = lua
DIST = ./dist

all: build build-cli

$(DIST):
	mkdir -p $(DIST)

build: $(DIST)
	$(LUA) ./src/cli.lua -e src.neblua -o ./dist/neblua.lua ./src/neblua.lua

build-cli: $(DIST)
	$(LUA) ./src/cli.lua -e src.cli -o ./dist/neblua-cli.lua ./src/cli.lua

check: build build-cli
	$(LUA) ./dist/neblua-cli.lua -e src.cli -o ./dist/temp.lua ./src/cli.lua
	diff ./dist/neblua-cli.lua ./dist/temp.lua

test:
	$(LUA) ./test.lua

.PHONY: clean
clean:
	rm -rf $(DIST)
	find . -type f -name '*.bundle.lua' -delete
