LUA = lua
DIST = ./dist

all: build

$(DIST):
	mkdir -p $(DIST)

build: $(DIST)
	$(LUA) ./src/cli.lua -e src.neblua -o ./dist/neblua.lua ./src/neblua.lua
	$(LUA) ./src/cli.lua -e src.cli -o ./dist/neblua-cli.lua ./src/cli.lua

.PHONY: check
check: build
	$(LUA) ./dist/neblua-cli.lua -e src.cli -o ./dist/temp.lua ./src/cli.lua
	diff ./dist/neblua-cli.lua ./dist/temp.lua

.PHONY: test
test:
	$(LUA) ./test.lua

.PHONY: clean
clean:
	rm -rf $(DIST)
	find . -type f -name '*.bundle.lua' -delete
