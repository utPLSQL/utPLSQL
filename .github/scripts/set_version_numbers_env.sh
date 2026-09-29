#!/bin/bash

build_no=$( expr ${GITHUB_RUN_NUMBER} + ${UTPLSQL_BUILD_NO_OFFSET} )
version=$(.github/scripts/get_project_version.sh)

echo "UTPLSQL_BUILD_NO=${build_no}" >> $GITHUB_ENV
echo "UTPLSQL_VERSION=${version}" >> $GITHUB_ENV
echo UTPLSQL_BUILD_VERSION=$(echo ${version} | sed -E "s/(v?[0-9]+\.)([0-9]+\.)([0-9]+)(-.*)?/\1\2\3\.${build_no}\4/")  >> $GITHUB_ENV
# Documentation of development versions does not include build number, so that it only changes when version changes
echo "UTPLSQL_DOCS_VERSION=${version}" >> $GITHUB_ENV
