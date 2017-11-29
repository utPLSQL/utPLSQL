#!/usr/bin/env bash

#When building a new version from a release branch, the version is taken from release branch name
if [[ "${CURRENT_BRANCH}" =~ ^release/v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
  version=${CURRENT_BRANCH#release\/}
else
  #Otherwise, version is taken from the VERSION file
  version=`cat VERSION`
  #When on develop branch, add "-develop" to the version text
  if [[ "${CURRENT_BRANCH}" == "develop" ]]; then
    version=`sed -r "s/(v?[0-9]+\.[0-9]+\.[0-9]+).*/\1-develop/" <<< "${version}"`
  fi
fi
echo ${version}
