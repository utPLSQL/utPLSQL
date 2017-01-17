#!/bin/bash
# Change working directory to script directory
cd "${0%/*}"
# Change back to root
cd ..
# Remove old release directory (Typically only on developer machine)
rm -rf release
# Create needed directories
mkdir -p release/docs/html
mkdir release/docs/markdown
mkdir release/source
# Copy files to various directories
cp -r docs release/docs/markdown
cp -r site release/docs/html 
cp -r source release/source
cp -r examples release/examples
cp -r readme.md release/ 
cp -r LICENSE release/
cp -r authors.md release/
cp -r CONTRIBUTING.md release/
cd release
zip -r ../utplsql.zip *
tar -zcvf ../utplsql.tar.gz *
