#!/usr/bin/env bash
#If building a new version from a release branch - then version is taken from release branch name
if [[ "${CURRENT_BRANCH}" =~ ^release/v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
  version=${CURRENT_BRANCH#release\/}
  version=`sed -r "s/(v?[0-9]+\.)([0-9]+\.)([0-9]+)(-.*)/\1\2\3\.${UTPLSQL_BUILD_NO}\4/" <<< "${version}"`
  echo ${version} > VERSION
else
  version=`cat VERSION`
fi
echo ${version}
