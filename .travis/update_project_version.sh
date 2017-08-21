#!/usr/bin/env bash

echo Current branch is "${CURRENT_BRANCH}"

echo Update version in project source files
find ${UTPLSQL_SOURCES_DIR} -type f -name '*' -exec sed -i -r "s/${UTPLSQL_VERSION_PATTERN}/${UTPLSQL_BUILD_VERSION}/" {} \;
echo Source files updated with version tag: ${UTPLSQL_BUILD_VERSION}

echo Update of sonar-project.properties sonar.projectVersion
sed -i -r "s/(sonar\.projectVersion=).*?/\1${UTPLSQL_VERSION}/" sonar-project.properties

echo Update VERSION file
echo ${UTPLSQL_VERSION} > VERSION

