#!/bin/bash
set -ev

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

cd test

time "$SQLCLI" ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@//${CONNECTION_STR} @install_tests.sql

cd ..


time utPLSQL-cli/bin/utplsql run ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@${CONNECTION_STR} \
-source_path=source -owner=ut3 \
-test_path=test -c \
-f=ut_documentation_reporter  -o=test_results.log -s \
-f=ut_coverage_sonar_reporter -o=coverage.xml \
-f=ut_coverage_html_reporter  -o=coverage.html \
-f=ut_coveralls_reporter      -o=coverage.json \
-f=ut_sonar_test_reporter     -o=test_results.xml \
-f=ut_junit_reporter          -o=junit_test_results.xml \
-f=ut_tfs_junit_reporter      -o=tfs_test_results.xml \
-scc
