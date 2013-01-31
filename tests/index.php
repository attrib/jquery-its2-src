<?php

define('TEST_ROOT_PATH', realpath(dirname(__FILE__)));

function parse_tests($xml, $implementer) {

    $tests = array();

    $test_suite = simplexml_load_file($xml);

    foreach ($test_suite->dataCategory as $data_category) {
        foreach ($data_category->inputfile as $input_file ) {
            foreach ($input_file->outputImplementors as $implementors) {
                if ($implementors['implementer'] == $implementer) {

                    $test = array();
                    $test['input'] = (string) $input_file['location'];
                    $test['output'] = (string) $implementors['location'];
                    $test['expected'] = (string) $input_file->expectedOutput['location'];
                    $test['description'] = (string) $input_file->description;

                    $category = (string) $data_category['name'];
                    if (!array_key_exists($category, $tests))
                        $tests[$category] = array();

                    $tests[$category][] = $test;
                }
            }
        }
    }

    return $tests;
}

function render_tests($tests) {

    foreach ($tests as $category => $test) {
        echo "<h2>$category</h2><br/>\n";
        echo "<ul>";
        foreach ($test as $t) {
            echo "<li>{$t['description']}<ul>";
            echo "<li>Input: <a href=\"ITS-2.0-Testsuite/its2.0/{$t['input']}\">{$t['input']}</a></li>";
            echo "<li>Output: <a href=\"ITS-2.0-Testsuite/its2.0/{$t['output']}\">{$t['output']}</a></li>";
            echo "<li>Expected: <a href=\"ITS-2.0-Testsuite/its2.0/{$t['expected']}\">{$t['expected']}</a></li>";
            $file = TEST_ROOT_PATH . '/ITS-2.0-Testsuite/its2.0/' . $t['input'];
            echo "<li><a href='test.php?input={$file}'>Test it!</a></li>";
            echo "</ul></li>";
        }
        echo "</ul>";
    }

    //TODO: Return the string don't echo it.
}

$tests = parse_tests(TEST_ROOT_PATH . '/ITS-2.0-Testsuite/its2.0/testsuiteMaster.xml', 'cocomore');
render_tests($tests);


?>
