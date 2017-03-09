#!/usr/bin/env bash

cd "${0%/*}"

#Assumptions:
# - update project version was executed using update_project_version.sh
# - docs were build and committed using build_docs.sh

echo Committing project version update and html docs
. ./commit_and_push.sh "Updated project version (${UTPLSQL_VERSION}) and added html docs [skip ci]"

echo Creating a release tag "${UTPLSQL_VERSION}"
. ./create_tag.sh

echo Preparing release branch for merge to develop
echo Removing generated html doc
rm -rf ${UTPLSQL_PROJECT_ROOT}/docs/html

echo Committing html docs cleanup
. ./commit_and_push.sh "Cleanup of release of version (${UTPLSQL_VERSION}) [skip ci]"
