#!/usr/bin/env bash

echo Updating version in project source files

find ${UTPLSQL_SOURCES_DIR} -type f -name '*' -exec sed -i -r "s/${UTPLSQL_VERSION_PLACEHOLDER}/\1${UTPLSQL_FULL_VERSION}/" {} \;

echo Source files updated with version tag: $UTPLSQL_FULL_VERSION

