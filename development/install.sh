#!/usr/bin/env bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. development/env.sh

header="******************************************************************************************"
if ! development/cleanup.sh; then
  echo -e ${header}"\nFailed to cleanup utPLSQL environment\n"${header}
  exit 1
fi
if ! .travis/install.sh; then
  echo -e ${header}"\nFailed to install utPLSQL from current branch into ${UT3_OWNER} schema\n"${header}
  exit 1
fi
if ! .travis/install_utplsql_release.sh; then
    echo -e ${header}"\nFailed to install utPLSQL from branch ${SELFTESTING_BRANCH} into ${UT3_RELEASE_VERSION_SCHEMA}\n"${header}
    exit 1
fi
if ! .travis/create_additional_grants_for_old_tests.sh; then
    echo -e ${header}"Failed to add grants needed old_tests\n"${header}
    exit 1
fi
