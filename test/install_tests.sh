#!/bin/bash
set -ev

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"
cd test

"$SQLCLI" ${UT3_TESTER_HELPER}/${UT3_TESTER_HELPER_PASSWORD}@//${CONNECTION_STR} @install_ut3_tester_helper.sql

"$SQLCLI" ${UT3_USER}/${UT3_USER_PASSWORD}@//${CONNECTION_STR} @install_ut3_user_tests.sql

"$SQLCLI" ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@//${CONNECTION_STR} @install_ut3_tester_tests.sql

