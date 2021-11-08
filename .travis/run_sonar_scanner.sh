#!/usr/bin/env bash

#Run Sonar based on conditions

MAIN_DEV_BRANCH="develop"

BRANCH_SONAR_PROPERTY="sonar.branch.name"
BRANCH_SONAR_TARGET_PROPERTY="sonar.branch.target"

PR_SONAR_BRANCH_PROPERTY="sonar.pullrequest.branch"
PR_KEY_PROPERTY="sonar.pullrequest.key"
PR_SONAR_BASE_PROPERTY="sonar.pullrequest.base"
PR_SONAR_TOKEN_PROPERTY="sonar.pullrequest.github.token.secured"

DB_URL_SONAR_PROPERTY="sonar.plsql.jdbc.url"
DB_DRIVER_PATH="sonar.plsql.jdbc.driver.path"

#Add property to file
function add_sonar_property {
    echo "$1=$2" >> sonar-project.properties
}


if [ "${PULL_REQUEST_NAME}" == "false" ]; then
    BRANCH=${BRANCH_NAME};
    PR_BRANCH=""
    echo "BRANCH=$BRANCH"
else 
    BRANCH=${PULL_REQUEST_BRANCH}
    PR_BRANCH=${BRANCH_NAME}
    echo "TRAVIS_BRANCH=$TRAVIS_BRANCH, PR=${PULL_REQUEST_NAME}, BRANCH=$BRANCH"

fi   


#Are we running on utPLSQL repo and not an external PR?
echo "Check if we running from develop or on branch"
if [ "${REPO_SLUG}" = "${UTPLSQL_REPO}" ] && [[ ! "${BRANCH}" =~ ^(release/v[0-9]+\.[0-9]+\.[0-9]+.*|"${MAIN_DEV_BRANCH}")$ ]]; then
    
    echo "" >> sonar-project.properties
    if [ "${PULL_REQUEST_NAME}" == "false" ]; then
        echo "Updating sonar properties to include branch ${BRANCH}"
        add_sonar_property "${BRANCH_SONAR_PROPERTY}" "${BRANCH}" 
        add_sonar_property "${BRANCH_SONAR_TARGET_PROPERTY}" "${MAIN_DEV_BRANCH}" 
     elif [ "${PR_SLUG}" = "${REPO_SLUG}" ]; then
       echo "Updating sonar properties to include pull request ${BRANCH}"
       add_sonar_property "${PR_SONAR_TOKEN_PROPERTY}" "${GITHUB_TRAVISCI_TOKEN}"
       add_sonar_property "${PR_SONAR_BRANCH_PROPERTY}" "${BRANCH}"
       add_sonar_property "${PR_KEY_PROPERTY}" "${PR}"
       add_sonar_property "${PR_SONAR_BASE_PROPERTY}" "${PR_BRANCH}"
     else
       echo "PR from external source no changes to properties."
     fi    
else
    echo "No need to update sonar we building on release or develop"
fi

#Address issue : Could not find ref 'develop' in refs/heads or refs/remotes/origin
git fetch --no-tags https://github.com/utPLSQL/utPLSQL.git +refs/heads/develop:refs/remotes/origin/develop

echo "Adding OJDBC Driver Path ${OJDBC_HOME}/ojdbc8.jar"
add_sonar_property "${DB_URL_SONAR_PROPERTY}" "jdbc:oracle:thin:@${CONNECTION_STR}"
add_sonar_property "${DB_DRIVER_PATH}" "${OJDBC_HOME}/ojdbc8.jar"


#Execute Sonar scanner
echo "Executing sonar scanner"
sonar-scanner
