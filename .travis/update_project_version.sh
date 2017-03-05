#!/usr/bin/env bash

echo Current branch is "${CURRENT_BRANCH}"

last_commit_user=`git log -1 --format=%an`
if [[ "${last_commit_user}" != "${UTPLSQL_BUILD_USER_NAME}" ]]; then
  if [[ "${CURRENT_BRANCH}" =~ ^release/v[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
    echo Updating version in project source files
    find ${UTPLSQL_SOURCES_DIR} -type f -name '*' -exec sed -i -r "s/(${UTPLSQL_VERSION_PLACEHOLDER} )[^']*(')?/\1${UTPLSQL_VERSION}\2/" {} \;
    echo Source files updated with version tag: $UTPLSQL_FULL_VERSION

    echo Update of sonar-project.properties sonar.projectVersion
    sed -i -r "s/(sonar\.projectVersion=).*?/\1${UTPLSQL_VERSION}/" sonar-project.properties
    echo ${UTPLSQL_VERSION} > VERSION

    #inspired by:
    # https://github.com/travis-ci/travis-ci/issues/1476
    # http://stackoverflow.com/questions/36915499/push-to-git-master-branch-from-travis-ci
    git config --global user.email "builds@travis-ci.com"
    git config --global user.name "${UTPLSQL_BUILD_USER_NAME}"

    git add .
    git commit -m 'Updated project version after building a release'
    echo pushing
    git push --quiet https://${github_api_token}@github.com/${UTPLSQL_REPO} HEAD:${CURRENT_BRANCH}
    echo Creating tag
    git tag ${UTPLSQL_VERSION} -a -m "Generated tag from TravisCI build $TRAVIS_BUILD_NUMBER"
    echo pushing tag
    git push --quiet https://${github_api_token}@github.com/${UTPLSQL_REPO} ${UTPLSQL_VERSION}
  else
    echo Not on a release branch, skipping project version update
  fi
fi
