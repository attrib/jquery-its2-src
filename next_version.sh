#!/bin/sh
VERSION=`cat VERSION`
rm VERSION
MINOR=`echo ${VERSION} | grep '[0-9]*$' -o`
MINOR=$((MINOR+1))
echo ${VERSION} | sed 's/\([0-9]*\)$/'"${MINOR}"'/' > VERSION
VERSION=`cat VERSION`
JQUERY_INFO=`cat release/its-parser.jquery.json | sed 's/\("version": \)"[0-9\.]*"/\1"'"$VERSION"'"/'
rm release/its-parser.jquery.json`
echo $JQUERY_INFO > release/its-parser.jquery.json
