#!/bin/bash
set -ev

cd test

"$SQLCLI" ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@//${CONNECTION_STR} @install_tests.sql

cd ..

utPLSQL-cli/bin/utplsql run ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@${CONNECTION_STR} \
-source_path=source -test_path=tests \
-f=ut_documentation_reporter  -c \
-f=ut_coverage_sonar_reporter -o=coverage.xml \
-f=ut_sonar_test_reporter     -o=test_results.xml
