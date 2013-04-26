JQuery ITS2.0 Source
====================

JQuery selector plugin for the [International Tag Standard 2.0 (ITS2.0)](http://www.w3.org/TR/its20/).
With this plugin it is possible to select HTML-nodes depending on ITS markup.

This is the original coffeescript source repository.
See the [jquery-its](https://github.com/attrib/jquery-its2) repository for already packaged files and more information.

There is also a bigger example repository ([jquery-its-example](https://github.com/attrib/jquery-its-example)),
where you can highlight and edit ITS Data.

Currently supported data categories from ITS 2.0:
* Translate
* Localization Note
* Storage Size
* Allowed Characters
* Text Analysis
* Terminology
* Directionality
* Domain
* Locale Filter
* Localization Quality Issue

Usage
-----

Get the created jquery.its-parser.js and link it in your project.
There are two new methods for jquery (jQuery.parseITS, jQuery.getITSData) and a new selector for each supported data category.

For all selectors parseITS has to be run once before.

### parseITS ( callback ) ###

Parse the current HTML and loads global rules. This step is important to use the selectors.
Otherwise global rules are not initialised and the selectors doesn't work.

```
$.parseITS();                   -> starts the parser
$.parseITS(function() {})       -> use callback to start working with selectors after the rules has been loaded and parsed
```

### getITSData ###

Get all the ITS Information from a specified node in the DOM.

```
$('span').getITSData()          -> get the ITS Data for this node
    returns a object
    {
      translate: true,
      term: false,
      dir: "ltr",
      locNote: "This is a Note.",
      locNoteType: "alert",
      domains: ["law"]
    }

- OR -

$.getITSData('span')            -> same as above
```

### getITSAnnotatorsRef( dataCategoryName ) ###

Get the [Annotators References](http://www.w3.org/International/multilingualweb/lt/drafts/its20/its20.html#its-tool-annotation) of the selected DOM nodes.

```
$('span').getITSAnnotatorsRef('textAnalysis')    -> get the annotators Reference of all spans
  returns ["http://enrycher.ijs.si"]
```

### :translate ###

Selector for the [translate](http://www.w3.org/TR/its20/#trans-datacat) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:translate')                -> select all nodes with translate = yes
$('*:translate(yes)')           -> select all nodes with translate = yes
$('*:translate(no)')            -> select all nodes with translate = no
```

### :locNote ###

Selector for the [localization note](http://www.w3.org/TR/its20/#locNote-datacat) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:locNote')                  -> select all nodes with a any localization note
$('*:locNote(any)')             -> select all nodes with a any localization note
$('*:locNote(description)')     -> select all nodes with a localization note from type description
$('*:locNote(alert)')           -> select all nodes with a localization note from type alert
```

### :storageSize ###

Selector for the [storage size](http://www.w3.org/TR/its20/#storagesize) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:storageSize')                  -> select all nodes with a any storage size
$('*:storageSize(size: 25)')        -> select all nodes with a storage size from 25
$('*:storageSize(size: >25)')       -> select all nodes with a storage size above 25 (also supported are >,!=,<)
$('*:storageSize(encoding: UTF-8)') -> select all nodes with a storage size encoding of UTF-8
$('*:storageSize(linebreak: lf)')   -> select all nodes with a storage size line break "lf"
$('*:storageSize(size: 25, linebreak: lf)') -> matching query can be combined with , (comma)
                                               everything has to be true to be returned
```

### :allowedCharacters ###

Selector for the [allowed characters](http://www.w3.org/TR/its20/#allowedchars) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:allowedCharacters')        -> select all nodes with a any allowed characters
$('*:allowedCharacters([a-Z])') -> select all nodes with the specified allowed characters ([a-Z])
```

### :textAnalysis ###

Selector for the [text analysis](http://www.w3.org/TR/its20/#textanalysis) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:textAnalysis')                        -> select all nodes with a any text analysis attribute
$('*:textAnalysis(taConfidence: 0.7)')     -> select all nodes with a confidence of 0.7
$('*:textAnalysis(taConfidence: >0.6)')    -> select all nodes with a confidence above 0.6 (also supported are >,!=,<)
$('*:textAnalysis(taIdentRef: http://dbpedia.org/resource/Dublin)')         -> select all nodes with a given IdentRef
$('*:textAnalysis(taClassRef: http://nerd.eurecom.fr/ontology#Location)')   -> select all nodes with a given ClassRef
$('*:textAnalysis(taSource: Wordnet3.0)')  -> select all nodes with a given Source
$('*:textAnalysis(taIdent: 301467919)')    -> select all nodes with a given Ident
$('*:textAnalysis(taConfidence: >0.5, taSource: Wordnet3.0)')               -> matching query can be combined with , (comma)
                                                                               everything has to be true to be returned
```

### :terminology ###

Selector for the [terminology](http://www.w3.org/TR/its20/#terminology) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:terminology')                        -> select all nodes which are a term
$('*:terminology(termConfidence: 0.7)')   -> select all nodes with a confidence of 0.7
$('*:terminology(termConfidence: >0.6)')  -> select all nodes with a confidence above 0.6 (also supported are >,!=,<)
$('*:terminology(termInfoRef: #TDPV)')    -> select all nodes with a given InfoRef
$('*:terminology(term: yes)')             -> select all nodes which are a term
$('*:terminology(term: no)')              -> select all nodes which are not a term
$('*:terminology(termConfidence: >0.5, term: yes)')  -> matching query can be combined with , (comma)
                                                        everything has to be true to be returned
```

### :dir ###

Selector for the [directionality](http://www.w3.org/TR/its20/#directionality) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:translate')                -> select all nodes with dir = ltr
$('*:translate(ltr)')           -> select all nodes with dir = ltr
$('*:translate(rtl)')            -> select all nodes with dir = rtl
```

### :localeFilter ###

Selector for the [locale filter](http://www.w3.org/TR/its20/#LocaleFilter) data category.

** For all selectors parseITS has to be run once before. **

```
$('*:localeFilter')                                   -> select all nodes which have a locale filter (not "include" - "*")
$('*:localeFilter(localeFilterList: "de-DE, de-CH")') -> select all nodes with the exactly language list of de-DE, de-CH
$('*:localeFilter(localeFilterType: include)')        -> select all nodes with the filter type of include
$('*:localeFilter(localeFilterType: exclude)')        -> select all nodes with the filter type of exclude
$('*:localeFilter(lang: de-DE)')                      -> select all nodes which should be included with de-DE
                                                         This is true, even if there are more items in the filter list
                                                         or when using *-DE, de-DE or * in filter list
$('*:localeFilter(lang: de-*)')                       -> You even can use * in the query here to,
                                                         see the detailed description from the standard
                                                         for more information
$('*:localeFilter(localeFilterType: include, localeFilterList: "de-DE, de-CH")')
                                                      -> matching query can be combined with , (comma)
                                                         everything has to be true to be returned
```

### :locQualityIssue ###

Selector for the [Localization Quality Issue](http://www.w3.org/TR/its20/#lqissue) data category.

All queries also handles standoff markup. If a node has a reference to a standoff markup
with multiple issues and the query is locQualityIssueSeverity: >50
then the node will return true, if at least one issue satisfy this query.

** For all selectors parseITS has to be run once before. **

```
$('*:locQualityIssue')                                         -> select all nodes which have a localization quality issue
$('*:locQualityIssue(locQualityIssueComment: "a comment.")')   -> select all nodes which have a specific comment
$('*:locQualityIssue(locQualityIssueEnabled: yes)')            -> select all nodes which are enabled (or not, when no)
$('*:locQualityIssue(locQualityIssueProfileRef: "http://example.org/qaMovel/v1")')
                                                               -> select all nodes which have a localization quality issue
$('*:locQualityIssue(locQualityIssueSeverity: 50)')            -> select all nodes which have a severity of 50
$('*:locQualityIssue(locQualityIssueSeverity: >50)')           -> select all nodes which have a severity above 50 (also supported are >,!=,<)
$('*:locQualityIssue(locQualityIssueType: misspelling)')       -> select all nodes which have a specific type
$('*:locQualityIssue(locQualityIssuesRef: locqualityissue9htmlstandoff.xml#lq1)')
                                                               -> select all nodes which have a specific reference to standoff issues
$('*:locQualityIssue(locQualityIssueSeverity: 50, locQualityIssueEnabled: yes)')
                                                               -> matching query can be combined with , (comma)
                                                                  everything has to be true to be returned
```

Build
-----

Run the `scripts/build_env.sh` once to setup node.js and every needed extension.

1. `make src` to generate all files
2. you will find the jquery.its-parser.js in the build directory
3. (Optional) run `make all` or `make test` to generate the expected data output
4. (Optional) check tests/ITS-2.0-Testsuite/its2.0/testSuiteDashboard.html for any errors for the cocomore implementation

Credits
-------

* [Cocomore AG](http://www.cocomore.com)
* Karl Fritsche (karl.fritsche@cocomore.com) - [attrib](http://drupal.org/user/619702)
* Alejandro Leiva (alejandro.leiva@cocomore.com) - [gloob](http://drupal.org/user/1866660)
* [MultilingualWeb-LT Working Group](http://www.w3.org/International/multilingualweb/lt/)

License
-------

[GNU General Public License, version 2](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html)
