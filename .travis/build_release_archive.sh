#!/bin/bash

# remove markdown documentation
rm -rf docs/*
# and replace it with generated html documentation from the ignored site folder
cp -r -v site/* docs

mv -f .gitattributes.release .gitattributes
git add .
git commit -m "tmp commit for building a release archive"

# git archive --prefix="utPLSQL${UTPLSQL_BUILD_VERSION}"/ -o "utPLSQL${UTPLSQL_BUILD_VERSION}".zip    --format=zip    HEAD
# git archive --prefix="utPLSQL${UTPLSQL_BUILD_VERSION}"/ -o "utPLSQL${UTPLSQL_BUILD_VERSION}".tar.gz --format=tar.gz HEAD

git archive --prefix=utPLSQL/ -o utPLSQL.zip    --format=zip    HEAD
git archive --prefix=utPLSQL/ -o utPLSQL.tar.gz --format=tar.gz HEAD
md5sum utPLSQL.zip  --tag > utPLSQL.zip.md5
md5sum utPLSQL.tar.gz  --tag > utPLSQL.tar.gz.md5

