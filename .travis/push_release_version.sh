#!/usr/bin/env bash

echo Current branch is "${CURRENT_BRANCH}"
if [[ "${CURRENT_BRANCH}" =~ ^release/v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then

    echo Current job number is "${TRAVIS_JOB_NUMBER}"
    if [[ "${TRAVIS_JOB_NUMBER}" =~ \.1$ ]]; then
        echo Publishing will be done for a job no. "${TRAVIS_JOB_NUMBER}"
        git add sonar-project.properties
        git add VERSION
        git commit -m 'Updated project version after building a release [skip ci]'

        echo Pushing to origin
        git push --quiet origin HEAD:${CURRENT_BRANCH}
    else
        echo Publishing will not be done for a job no.: "${TRAVIS_JOB_NUMBER}"
    fi
else
    echo Not on a release branch - skipping publishing of version
fi
