#!/usr/bin/env bash

MAIN_DEV_BRANCH="develop"

BRANCH_SONAR_PROPERTY="sonar.branch.name"
BRANCH_SONAR_TARGET_PROPERTY="sonar.branch.target"

PR_SONAR_BRANCH_PROPERTY="sonar.pullrequest.branch"
PR_KEY_PROPERTY="sonar.pullrequest.key"
PR_SONAR_BASE_PROPERTY="sonar.pullrequest.base"
PR_SONAR_TOKEN_PROPERTY="sonar.pullrequest.github.token.secured"

#Add property to file
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


#Are we running on develop branch ?
echo "Check if we running from develop or on branch"
if [ "${TRAVIS_REPO_SLUG}" = "${UTPLSQL_REPO}" ] && [[ ! "${BRANCH}" =~ ^(release/v[0-9]+\.[0-9]+\.[0-9]+.*|"${MAIN_DEV_BRANCH}")$ ]]; then
    
    if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then 
        echo "Updating sonar properties to include branch name"
        add_sonar_property "${BRANCH_SONAR_PROPERTY}" "${BRANCH}" 
        add_sonar_property "${BRANCH_SONAR_TARGET_PROPERTY}" "${MAIN_DEV_BRANCH}" 
     else
       echo "Updating sonar properties to include pull request name"
       add_sonar_property "${PR_SONAR_TOKEN_PROPERTY}" "${GITHUB_TRAVISCI_TOKEN}"
       add_sonar_property "${PR_SONAR_BRANCH_PROPERTY}" "${BRANCH}"
       add_sonar_property "${PR_KEY_PROPERTY}" "${PR}"
       add_sonar_property "${PR_SONAR_BASE_PROPERTY}" "${PR_BRANCH}"
     fi    
else
    echo "No need to update sonar we building on release or develop"
fi

#debug
cat sonar-project.properties

#Execute Sonar scanner
#sonar-scanner