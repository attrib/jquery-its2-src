JQuery ITS2.0 Parser
===================

This is a JQuery Plugin to parse a HTML file for ITS Markup and select HTML-nodes with a specific ITS attribute.

Usage
-----

Get the builded jquery.its-parser.js and link it in your project.

Examples:

``` 
$('*:translate')			-> select all nodes with translate = yes
$('*:translate(no)')			-> select all nodes with translate = no
//TODO add more examples
```

Build
-----

1. Run the `scripts/build_env.sh` once to setup node.js and every needed extension.
1. `make all` to generate all files
1. test

You can find the created JS files in the build directory.

