#!/bin/bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. ./development/env.sh

header="******************************************************************************************"
if ! development/cleanup.sh; then
  echo -e ${header}"\nFailed to cleanup utPLSQL environment\n"${header}
  exit 1
fi
if ! .github/scripts/install.sh; then
  echo -e ${header}"\nFailed to install utPLSQL from current branch into ${UT3_DEVELOP_SCHEMA} schema\n"${header}
  exit 1
fi
if ! .github/scripts/create_test_users.sh; then
  echo -e ${header}"\nFailed to create test users from current branch\n"${header}
  exit 1
fi
if ! .github/scripts/install_utplsql_release.sh; then
    echo -e ${header}"\nFailed to install utPLSQL from branch ${SELFTESTING_BRANCH} into ${UT3_RELEASE_VERSION_SCHEMA}\n"${header}
    exit 1
fi
