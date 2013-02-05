JQuery ITS2.0 Source
====================

JQuery selector plugin for the [International Tag Standard 2.0 (ITS2.0)](http://www.w3.org/TR/its20/).
With this plugin it is possible to select HTML-nodes depending on ITS markup.

This is the original coffeescript source repository.
See the [jquery-its](https://github.com/attrib/jquery-its2) repository for already packaged files and more information.

Usage
-----

Get the created jquery.its-parser.js and link it in your project.

Examples:

``` 
$('*:translate')                -> select all nodes with translate = yes
$('*:translate(no)')            -> select all nodes with translate = no
//TODO add more examples
```

Currently supported data categories:
* Translate
* Localization Note
* Storage Size
* Allowed Characters

Build
-----

Run the `scripts/build_env.sh` once to setup node.js and every needed extension.

1. `make all` to generate all files
1. you will find the jquery.its-parser.js in the build directory

Credits
-------

* [Cocomore AG](http://www.cocomore.com)
** Karl Fritsche - [attrib](http://drupal.org/user/619702)
** Alejandro Leiva - [gloob](http://drupal.org/user/1866660)
* [MultilingualWeb-LT Working Group](http://www.w3.org/International/multilingualweb/lt/)

License
-------

[GNU General Public License, version 2](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
