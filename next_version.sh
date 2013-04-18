#!/bin/sh
VERSION=`cat VERSION`
rm VERSION
if [ "$1" = "major" ]; then
  MAJOR=`echo ${VERSION} | grep '[0-9]*' -o | sed -n '2p'`
  MAJOR=$((MAJOR+1))
  echo ${VERSION} | sed 's/\([0-9]*\)\(.[0-9]*\)$/'"${MAJOR}"'.0/' > VERSION
else
  MINOR=`echo ${VERSION} | grep '[0-9]*$' -o`
  MINOR=$((MINOR+1))
  echo ${VERSION} | sed 's/\([0-9]*\)$/'"${MINOR}"'/' > VERSION
fi

VERSION=`cat VERSION`
JQUERY_INFO=`cat release/its-parser.jquery.json | sed 's/\("version": \)"[0-9\.]*"/\1"'"$VERSION"'"/'`
rm release/its-parser.jquery.json
echo "$JQUERY_INFO" > release/its-parser.jquery.json
DISCLAIMER=`cat header.txt | sed 's/\(Version: \)[0-9\.]*/\1'"$VERSION"'/'`
echo "$DISCLAIMER" > header.txt
