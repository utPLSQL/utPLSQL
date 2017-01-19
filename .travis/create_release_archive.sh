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
cp -r client_source release/client_source
cp -r source release/source
cp -r examples release/examples
cp -r readme.md release/ 
cp -r LICENSE release/
cp -r authors.md release/
cp -r CONTRIBUTING.md release/
cd release
#Although the $TRAVIS_TAG versions are the only one used.  They are conditional,
#and we want the process always run to insure we don't have problems with building archive
#when we finally tag a release
zip -r ../utPLSQL.zip *
tar -zcvf ../utPLSQL.tar.gz *
#Name of archive will match tag name for a release.
if [ -n "$TRAVIS_TAG" ]; then 
cd ..
cp utPLSQL.zip utPLSQL$TRAVIS_TAG.zip
cp utPLSQL.tar.gz utPLSQL$TRAVIS_TAG.tar.gz
fi