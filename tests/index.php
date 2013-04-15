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

function parse_results($inputFile, $implementer) {

  static $resultFile = null;
  if (!isset($resultFile)) {
    $resultFile = simplexml_load_file(TEST_ROOT_PATH . '/ITS-2.0-Testsuite/its2.0/testSuiteDashboard.xml');
    foreach ($resultFile->getNamespaces() as $prefix => $namespace) {
      if ($prefix == '') $prefix = 'm';
      $resultFile->registerXPathNamespace($prefix, $namespace);
    }
  }

  $result = $resultFile->xpath('//m:inputfile[@location="' . $inputFile . '"]/m:outputImplementors[@implementer="' . $implementer . '"]');
  if (count($result) != 1) {
    return array('error' => 'Missing Information in testSuiteDashboard.xml');
  }
  $result = $result[0];

  return $result;
}

function render_tests($tests) {

    foreach ($tests as $category => $test) {
        echo "<h2>$category</h2><br/>\n";
        echo '<a href="ITS-2.0-Testsuite/its2.0/testSuiteDashboard.html#' . str_replace(' ', '', $category) . '">' . $category . ' Results</a><br/>' . "\n";
        echo "<ul>";
        foreach ($test as $t) {
            echo "<li>{$t['description']}<ul>";
            echo "<li>Input: <a href=\"ITS-2.0-Testsuite/its2.0/{$t['input']}\">{$t['input']}</a></li>";
            echo "<li>Output: <a href=\"ITS-2.0-Testsuite/its2.0/{$t['output']}\">{$t['output']}</a></li>";
            echo "<li>Expected: <a href=\"ITS-2.0-Testsuite/its2.0/{$t['expected']}\">{$t['expected']}</a></li>";
            $file = TEST_ROOT_PATH . '/ITS-2.0-Testsuite/its2.0/' . $t['input'];
            echo "<li><a href='test.php?input={$file}'>Test it!</a></li>";
            $result = parse_results($t['input'], 'cocomore');
            $test_id = substr($t['input'], strrpos($t['input'], '/')+1);
            $test_id = substr($test_id, 0, strrpos($test_id, '.'));
            echo '<li>Teststatus: <a href="ITS-2.0-Testsuite/its2.0/testSuiteDashboard.html#t-' . $test_id . '">';
            if (empty($result->error)) {
              echo 'OK';
            }
            else {
              echo '<span style="color: red">FAILED</span>';
            }
            echo "</a>";
            if (!empty($result->error)) {
              echo "<ul>";
              foreach ($result->error as $error) {
                echo '<li>' . str_replace("\n", "<br>\n", trim((string) $error)) . '</li>';
              }
              echo "</ul>";
            }
            echo "</li></ul></li>";
        }
        echo "</ul>";
    }

    //TODO: Return the string don't echo it.
}

function write_test_bash($tests) {
  $content = "#!/bin/sh\n";
  foreach ($tests as $category => $test) {
    foreach ($test as $t) {
      $content .= "phantomjs ".TEST_ROOT_PATH."/test.js ".TEST_ROOT_PATH."/ITS-2.0-Testsuite/its2.0/{$t['input']} ".TEST_ROOT_PATH."/ITS-2.0-Testsuite/its2.0/{$t['output']}\n";
    }
  }
  file_put_contents(TEST_ROOT_PATH. '/test_all.sh', $content);
}

$tests = parse_tests(TEST_ROOT_PATH . '/ITS-2.0-Testsuite/its2.0/testsuiteMaster.xml', 'cocomore');
render_tests($tests);
write_test_bash($tests);

?>
