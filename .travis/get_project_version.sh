#!/usr/bin/env bash
#If building a new version from a release branch - then version is taken from release branch name
if [[ "${CURRENT_BRANCH}" =~ ^release/v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
  version=${CURRENT_BRANCH#release\/}
elif [[ "${TRAVIS_TAG}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
  version=${TRAVIS_TAG}
else
  version=`cat VERSION`
fi
echo ${version}
