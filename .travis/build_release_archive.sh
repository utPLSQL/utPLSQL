#!/bin/bash

# remove markdown documentation
rm -rf docs/*
# and replace it with generated html documentation from the ignored site folder
cp -r -v site/* docs

mv -f .gitattributes.release .gitattributes
git add .
git commit -m "tmp commit for building a release archive"

git archive --prefix="utPLSQL"/ -o "utPLSQL".zip    --format=zip    HEAD
git archive --prefix="utPLSQL"/ -o "utPLSQL".tar.gz --format=tar.gz HEAD


