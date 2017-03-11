#!/usr/bin/env bash

COMMIT_SHA=`git rev-parse HEAD`

#github API documentation: https://developer.github.com/v3/repos/releases/#create-a-release
#using https://stedolan.github.io/jq/
curl -H "Authorization: token ${github_api_token}" \
-X POST --data '{"name":"'${UTPLSQL_VERSION}'","tag_name":"'${UTPLSQL_VERSION}'","target_commitish":"'${COMMIT_SHA}'","prerelease":true' "https://api.github.com/repos/${UTPLSQL_REPO}/releases"
