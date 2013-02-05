SRC=$(wildcard src/*.coffee)
TEST=$(wildcard tests/*.coffee)
BUILD=$(SRC:src/%.coffee=build/%.js)
TESTS=$(TEST:tests/%.coffee=tests/%.js)

build/%.js: src/%.coffee
	coffee -cbp $< > $@

tests/%.js: tests/%.coffee
	coffee -cbp $< > $@

src: $(BUILD)
	cat $(BUILD) | uglifyjs -bo build/jquery.its-parser.js

test: $(TESTS)

clean:
	rm -f $(BUILD) $(TESTS) build/jquery.its-parser.js

release: clean src
	rm -f release/jquery.its-parser.js release/jquery.its-parser.min.js
	cat $(BUILD) | uglifyjs -bo release/jquery.its-parser.js
	cat $(BUILD) | uglifyjs -o release/jquery.its-parser.min.js

all: src test
