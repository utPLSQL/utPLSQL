#!/usr/bin/env bash

#When building a new version from a release branch, the version is taken from release branch name
if [[ "${CI_ACTION_REF_NAME}" =~ ^release/v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
  version=${CI_ACTION_REF_NAME#release\/}
else
  #Otherwise, version is taken from the VERSION file
  version=`cat VERSION`
  #When on develop branch, add "-develop" to the version text
  if [[ "${CI_ACTION_REF_NAME}" == "develop" ]]; then
    version=`sed -E "s/(v?[0-9]+\.[0-9]+\.[0-9]+).*/\1-develop/" <<< "${version}"`
  fi
fi
echo ${version}
