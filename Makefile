SRC=src/xpath.coffee src/rules.coffee src/rules-controller.coffee src/rule-param.coffee $(wildcard src/rules/*.coffee) src/jquery-its-plugin.coffee
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
	uglifyjs $(BUILD) -bo build/jquery.its-parser.js
	(echo '(function($$) {' && cat build/jquery.its-parser.js && echo '})(jQuery);') > tmp
	mv tmp build/jquery.its-parser.js

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
	uglifyjs $(BUILD) -bo release/jquery.its-parser.js
	uglifyjs $(BUILD) -o release/jquery.its-parser.min.js
	sh next_version.sh
	(cat header.txt && echo '(function($$) {' && cat release/jquery.its-parser.js && echo '})(jQuery);') > tmp
	mv tmp release/jquery.its-parser.js
	(cat header.txt && echo '(function($$) {' && cat release/jquery.its-parser.min.js && echo '})(jQuery);') > tmp
	mv tmp release/jquery.its-parser.min.js

all: src test
