#!/usr/bin/env bash

#inspired by:
# https://github.com/travis-ci/travis-ci/issues/1476
# http://stackoverflow.com/questions/36915499/push-to-git-master-branch-from-travis-ci
current_dir=`pwd`
commit_message="${1}"

cd "${UTPLSQL_PROJECT_ROOT}"

git config --global user.email "builds@travis-ci.com"
git config --global user.name "${UTPLSQL_BUILD_USER_NAME}"

echo Adding new/modified/removed files
git add --all .
echo Commiting changes
git commit --quiet -m "${commit_message}"
echo Pushing

# As suggested here: https://github.com/blog/1270-easier-builds-and-deployments-using-git-over-https-and-oauth
#   "To avoid writing tokens to disk, don't clone. Instead, just use the full git URL in your push/pull operations (with `.git` suffix)"
git push --quiet https://${github_api_token}@github.com/${UTPLSQL_REPO}.git HEAD:${CURRENT_BRANCH}

cd "${current_dir}"
