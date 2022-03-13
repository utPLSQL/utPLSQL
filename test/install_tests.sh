#!/bin/bash
set -ev

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}


"$SQLCLI" UT3_TESTER_HELPER/ut3@//${CONNECTION_STR} @install_ut3_tester_helper.sql

"$SQLCLI" UT3_USER/ut3@//${CONNECTION_STR} @install_ut3_user_tests.sql

"$SQLCLI" UT3_TESTER/ut3@//${CONNECTION_STR} @install_ut3_tester_tests.sql

