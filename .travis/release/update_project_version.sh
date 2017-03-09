#!/usr/bin/env bash

echo Updating version in project source files
find ${UTPLSQL_SOURCES_DIR} -type f -name '*' -exec sed -i -r "s/(${UTPLSQL_VERSION_PLACEHOLDER} )[^']*(')?/\1${UTPLSQL_VERSION}\2/" {} \;

echo Update of sonar-project.properties sonar.projectVersion
sed -i -r "s/(sonar\.projectVersion=).*?/\1${UTPLSQL_VERSION}/" sonar-project.properties
echo Setting project version in VERSION file
echo ${UTPLSQL_VERSION} > VERSION
