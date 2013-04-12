SRC=$(wildcard src/*.coffee)
TEST=$(wildcard tests/*.coffee)
BUILD=$(SRC:src/%.coffee=build/%.js)
TESTS=$(TEST:tests/%.coffee=tests/%.js)
VERSION=$(shell cat VERSION)
MINOR=$(shell cat VERSION | grep '[0-9]*$' -o)

build/%.js: src/%.coffee
	coffee -cbp $< > $@

tests/%.js: tests/%.coffee
	coffee -cbp $< > $@

src: $(BUILD)
	cat $(BUILD) | uglifyjs -bo build/jquery.its-parser.js

test: $(TESTS)
	php tests/index.php >> /dev/null
	find tests/ITS-2.0-Testsuite/its2.0/outputimplementors/cocomore -name *.txt* -exec rm {} \;
	sh tests/test_all.sh
	java -jar tests/saxon.jar tests/ITS-2.0-Testsuite/its2.0/testsuiteMaster.xml tests/ITS-2.0-Testsuite/its2.0/testsuiteDashboard.xsl -o:tests/ITS-2.0-Testsuite/its2.0/testSuiteDashboard.html
	rm tests/test_all.sh

clean:
	rm -f $(BUILD) $(TESTS) build/jquery.its-parser.js tests/test_all.sh
	find tests/ITS-2.0-Testsuite -name *.updated.html -exec rm {} \;

release: clean src
	rm -f release/jquery.its-parser.js release/jquery.its-parser.min.js
	cat $(BUILD) | uglifyjs -bo release/jquery.its-parser.js
	cat $(BUILD) | uglifyjs -o release/jquery.its-parser.min.js
	sh next_version.sh

all: src test
