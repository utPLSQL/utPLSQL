#!/bin/bash

mv -f .gitattributes.release .gitattributes
git add .
git commit -m "tmp commit for building a release archive"

git archive --prefix="utPLSQL${UTPLSQL_BUILD_VERSION}"/ -o "utPLSQL${UTPLSQL_BUILD_VERSION}".zip    --format=zip    HEAD
git archive --prefix="utPLSQL${UTPLSQL_BUILD_VERSION}"/ -o "utPLSQL${UTPLSQL_BUILD_VERSION}".tar.gz --format=tar.gz HEAD


