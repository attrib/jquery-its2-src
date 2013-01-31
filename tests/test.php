<?php

define('TEST_ROOT_PATH', realpath(dirname(__FILE__)));
define('DEBUG', FALSE);

if (isset($_GET['input']))
    $input = $_GET['input'];
else
    echo "I cannot work without input parameter.";

// TODO: File exists...

// Modifying ITS rules src to correct location from here.
$target = str_replace(TEST_ROOT_PATH . "/", '', $input);
$target = str_replace(basename($input), '', $target);

$scripts = '<script data-test="mlw-lt" src="../../../../../../lib/jquery-1.8.3.min.js"></script>
    <script data-test="mlw-lt" src="../../../../../../build/jquery-its-plugin.min.js"></script>
    <script data-test="mlw-lt" src="../../../../../its-translate.test.js"></script>'."\n";

$test = file_get_contents($input);
$last_head = strrpos($test, '</head>');
if ($last_head === false) {
    $test_output = str_replace('</head>', $scripts.'</head>', $test);
} else {
    $test_output = substr($test, 0, $last_head) . $scripts . substr($test, $last_head, strlen($test) - 1);
}

file_put_contents($input . '.updated.html', $test_output);
header("Location: " . $target . basename($input) . '.updated.html');

/*
$doc = new DOMDocument();
$doc->loadHTMLFile($input);

$head = $doc->getElementsByTagName('head')->item(0);

$links = $doc->getElementsByTagName('link');
foreach ($links as $link) {
    if ($link->getAttribute('rel') == "its-rules") {
        $href = $link->getAttribute('href');
        $href = $target . $href;
        $link->setAttribute('href', $href);
    }
}

// Adding own script elements.
$jquery = $doc->createElement('script');
$jquery->setAttribute('src', '../lib/jquery-1.8.3.min.js');
$head->appendChild($jquery);

if (DEBUG) {
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/01.xpath.js');
  $head->appendChild($its_plugin);
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/02.rules.js');
  $head->appendChild($its_plugin);
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/03.rules-controller.js');
  $head->appendChild($its_plugin);
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/04.rule-translate.js');
  $head->appendChild($its_plugin);
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/05.rule-locnote.js');
  $head->appendChild($its_plugin);
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/06.rule-storagesize.js');
  $head->appendChild($its_plugin);
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/07.rule-allowedcharacters.js');
  $head->appendChild($its_plugin);
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/jquery-its-plugin.js');
  $head->appendChild($its_plugin);
}
else {
  $its_plugin = $doc->createElement('script');
  $its_plugin->setAttribute('src', '../build/jquery-its-plugin.min.js');
  $head->appendChild($its_plugin);
}
$its_translate = $doc->createElement('script');
$its_translate->setAttribute('src', 'its-translate.test.js');
$head->appendChild($its_translate);


$doc->saveHTMLFile(TEST_ROOT_PATH . "/processed/" . basename($input));

echo $doc->saveHTML();
*/

?>