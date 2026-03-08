#!/bin/bash

build_no=$(cat BUILD_NO)
version=${CI_ACTION_REF_NAME}

echo "UTPLSQL_BUILD_NO=${build_no}" >> $GITHUB_ENV
echo "UTPLSQL_VERSION=${version}" >> $GITHUB_ENV
echo UTPLSQL_BUILD_VERSION=$(echo ${version} | sed -E "s/(v?[0-9]+\.)([0-9]+\.)([0-9]+)(-.*)?/\1\2\3\.${build_no}\4/")  >> $GITHUB_ENV

