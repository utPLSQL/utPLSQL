#!/usr/bin/env bash
echo `sed -r "s/(v?[0-9]+\.)([0-9]+\.)([0-9]+)(-.*)?/\1\2\3\.${UTPLSQL_BUILD_NO}\4/" <<< "${UTPLSQL_VERSION}"`
