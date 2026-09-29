#!/bin/bash

build_no=$(cat BUILD_NO)
version=${CI_ACTION_REF_NAME}
build_version=$(echo ${version} | sed -E "s/(v?[0-9]+\.)([0-9]+\.)([0-9]+)(-.*)?/\1\2\3\.${build_no}\4/")

echo "UTPLSQL_BUILD_NO=${build_no}" >> $GITHUB_ENV
echo "UTPLSQL_VERSION=${version}" >> $GITHUB_ENV
echo "UTPLSQL_BUILD_VERSION=${build_version}" >> $GITHUB_ENV
# Documentation of released versions includes build number
echo "UTPLSQL_DOCS_VERSION=${build_version}" >> $GITHUB_ENV
