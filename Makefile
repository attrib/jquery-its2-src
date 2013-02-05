SRC=$(wildcard src/*.coffee)
TEST=$(wildcard tests/*.coffee)
BUILD=$(SRC:src/%.coffee=build/%.js)
TESTS=$(TEST:tests/%.coffee=tests/%.js)

build/%.js: src/%.coffee
	coffee -cbp $< > $@

tests/%.js: tests/%.coffee
	coffee -cbp $< > $@

src: $(BUILD)

test: $(TESTS)

release:
	cat $(BUILD) | uglifyjs -bo build/jquery-its.min.js

clean:
	rm -f $(BUILD) $(TESTS)
	rm -f build/jquery-its-plugin.min.js

all: src test release
