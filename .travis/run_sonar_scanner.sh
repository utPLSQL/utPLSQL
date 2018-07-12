#!/usr/bin/env bash

MAIN_DEV_BRANCH="develop"
BRANCH_SONAR_PROPERTY="sonar.branch.name"
BRANCH_SONAR_TARGET_PROPERTY="sonar.branch.target"

function add_sonar_property {

    echo "$1=$2" >> sonar-project.properties
}

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then 
    BRANCH=$TRAVIS_BRANCH;
    PR_BRANCH=""
    echo "BRANCH=$BRANCH"
else 
    BRANCH=$TRAVIS_PULL_REQUEST_BRANCH
    PR_BRANCH=$TRAVIS_BRANCH
    echo "TRAVIS_BRANCH=$TRAVIS_BRANCH, PR=$PR, BRANCH=$BRANCH"

fi   


# We are updating sonar_properties only when is not a develop
# if its a pull request we will create a separate 
if [ "${TRAVIS_REPO_SLUG}" = "${UTPLSQL_REPO}" ] && [[ ! "${BRANCH}" =~ ^(release/v[0-9]+\.[0-9]+\.[0-9]+.*|"${MAIN_DEV_BRANCH}")$ ]]; then
    echo "Updating sonar properties to include branch name"

    add_sonar_property "${BRANCH_SONAR_PROPERTY}" "${BRANCH}" 
    
    if [ ! -z "$PR_BRANCH" ];  then
        echo "Updating sonar properties to include pr target branch name"
	     add_sonar_property "${BRANCH_SONAR_TARGET_PROPERTY}" "${PR_BRANCH}" 
    else
        add_sonar_property "${BRANCH_SONAR_TARGET_PROPERTY}" "${MAIN_DEV_BRANCH}" 
    fi
         
else
    echo "No need to update sonar we building on release or develop"
fi

#Execute Sonar scanner
sonar-scanner