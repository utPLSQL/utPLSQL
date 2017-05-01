#!/bin/bash

mv -f .gitattributes.release .gitattributes
git add .
git commit -m "tmp commit for building a release archive"

git archive --prefix="utPLSQL"/ -o "utPLSQL".zip    --format=zip    HEAD
git archive --prefix="utPLSQL"/ -o "utPLSQL".tar.gz --format=tar.gz HEAD


