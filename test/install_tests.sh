#!/bin/bash
set -ev

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}


"$SQLCLI" ${UT3_TESTER_HELPER}/${UT3_TESTER_HELPER_PASSWORD}@//${CONNECTION_STR} @install_ut3_tester_helper.sql

"$SQLCLI" ${UT3_USER}/${UT3_USER_PASSWORD}@//${CONNECTION_STR} @install_ut3_user_tests.sql

"$SQLCLI" ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@//${CONNECTION_STR} @install_ut3_tester_tests.sql

