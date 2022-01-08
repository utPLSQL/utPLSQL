#!/usr/bin/env bash

set -v
echo Current branch is "${CURRENT_BRANCH}"
echo "Committing version & buildNo into branch (${CURRENT_BRANCH})"
git add sonar-project.properties
git add VERSION
git add source/*
git add docs/*
git commit -m 'Updated project version after build [skip ci]'
echo "Pushing to origin"
git push --quiet origin HEAD:${CURRENT_BRANCH}
