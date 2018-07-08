#!/bin/bash

# Trigger a new Travis-CI job.
# Ordinarily, a new Travis job is triggered when a commit is pushed to a
# GitHub repository.  The trigger-travis.sh script provides a programmatic
# way to trigger a new Travis job.

# To use this script to trigger a dependent build in Travis, do two things:
#
# 1. Set an environment variable TRAVIS_ACCESS_TOKEN by navigating to
#   https://travis-ci.org/MYGITHUBID/MYGITHUBPROJECT/settings
# The TRAVIS_ACCESS_TOKEN environment variable will be set when Travis runs
# the job, but won't be visible to anyone browsing https://travis-ci.org/.
#


TRAVIS_URL=travis-ci.org
BRANCH=develop
USER="utPLSQL"
RESULT=1
declare -a REPO_MATRIX=("utPLSQL-java-api" "utPLSQL-v2-v3-migration" "utPLSQL-cli")

TOKEN=$1

if [ -n "$TRAVIS_REPO_SLUG" ] ; then
    MESSAGE=",\"message\": \"Triggered by upstream build of $TRAVIS_REPO_SLUG commit "`git rev-parse --short HEAD`"\""
else
    MESSAGE=",\"message\": \"Triggered manually from shell\""
fi

## For debugging:
# echo "TOKEN=$TOKEN"
# echo "MESSAGE=$MESSAGE"

body="{
\"request\": {
  \"branch\":\"$BRANCH\"
  $MESSAGE
}}"

for DOWNSTREAM_BUILD in "${REPO_MATRIX[@]}"; do     

    curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Travis-API-Version: 3" \
     -H "Authorization: token ${TOKEN}" \
     -d "$body" \
     https://api.${TRAVIS_URL}/repo/${USER}%2F${DOWNSTREAM_BUILD}/requests \
     | tee ${DOWNSTREAM_BUILD}-output.txt

     if grep -q '"@type": "error"' ${DOWNSTREAM_BUILD}-output.txt; then
       RESULT=0
       echo ""
       echo "Failed to start ${DOWNSTREAM_BUILD}"
       echo ""
     fi
     if grep -q 'access denied' ${DOWNSTREAM_BUILD}-output.txt; then
       RESULT=0
       echo ""
       echo "Failed to start ${DOWNSTREAM_BUILD}"
       echo ""
     fi
     
done

if [[ RESULT -eq 0 ]]; then
    exit 1
fi
