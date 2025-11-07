LUA = lua
DIST = ./dist
LIB = ./lib
TEST_LIB = $(LIB)/test.lua

all: build

$(DIST):
	mkdir -p $(DIST)

build: $(DIST)
	$(LUA) ./src/cli.lua -e src.neblua -o ./dist/neblua.lua
	$(LUA) ./src/cli.lua -e src.cli -o ./dist/neblua-cli.lua

$(TEST_LIB):
	mkdir -p $(LIB)
	curl -sSL https://github.com/Tsukina-7mochi/lua-testing-library/releases/latest/download/test.lua > $(TEST_LIB)

.PHONY: test-self-build
test-self-build: build
	$(LUA) ./dist/neblua-cli.lua -e src.cli -o ./dist/temp.lua ./src/cli.lua
	test -z "$$(diff ./dist/neblua-cli.lua ./dist/temp.lua)"

.PHONY: test
test: $(TEST_LIB)
	$(LUA) ./test/test.lua

.PHONY: clean
clean:
	rm -rf $(DIST)
	find . -type f -name '*.bundle.lua' -delete
