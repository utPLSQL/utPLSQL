#!/usr/bin/env bash

UTPLSQL_VERSION_PATTERN="v?([0-9]+\.){3}[0-9]+[^']*"

echo Current branch is "${CURRENT_BRANCH}"

echo Update version in project source files
find source -type f -name '*' -exec sed -i -r "s/${UTPLSQL_VERSION_PATTERN}/${UTPLSQL_BUILD_VERSION}/" {} \;
echo Source files updated with version tag: ${UTPLSQL_BUILD_VERSION}

echo Update version in documentation files
find docs -type f -name '*.md' -exec sed -i -r "s/(badge\/version-).*(-blue\.svg)/\1${UTPLSQL_BUILD_VERSION/-/--}\2/" {} \;

echo Update of sonar-project.properties sonar.projectVersion
sed -i -r "s/(sonar\.projectVersion=).*?/\1${UTPLSQL_VERSION}/" sonar-project.properties

echo Update VERSION file
echo ${UTPLSQL_VERSION} > VERSION

