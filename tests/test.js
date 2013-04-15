/**
 * Phantom Test JS file.
 * Load the given HTML input file and writes out the text of the textfield into the expected data folder.
 */

var page = require('webpage').create(),
  system = require('system'),
  fs     = require('fs');

if (system.args.length != 3 || !system.args[1] || !system.args[2]) {
  console.log("There are two arguments required. First argument should be the HTML input file and the other one the output file.");
  phantom.exit();
}

page.onConsoleMessage = function (msg) {
  console.log(msg);
};

page.onError = function(msg, trace) {
  var msgStack = ['ERROR: ' + msg];
  if (trace) {
    msgStack.push('TRACE:');
    trace.forEach(function(t) {
      msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function + '")' : ''));
    });
  }
  console.error(msgStack.join('\n'));
};

page.open(system.args[1], function (status) {
  page.injectJs("../lib/jquery-1.8.3.min.js");
  page.injectJs("../build/jquery.its-parser.js");
  page.injectJs("./its-translate.test.js");
  var testOutput = page.evaluate(function() {
    try {
      window.testFile();
      return $('#its-result').text();
    }
    catch(e) {
      console.log(window.location.pathname + ": " + e.message);
      return e.stack + "\n";
    }
  });
  fs.write(system.args[2], testOutput, 'w');
  phantom.exit();
});
