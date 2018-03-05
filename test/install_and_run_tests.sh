#!/bin/bash
set -ev


#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

cd test

"$SQLCLI" ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@//${CONNECTION_STR} @install_tests.sql

cd ..

utPLSQL-cli/bin/utplsql run ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@${CONNECTION_STR} \
-source_path=source -owner=ut3 \
-test_path=test -c \
-f=ut_documentation_reporter  -o=test_results.log -s \
-f=ut_coverage_sonar_reporter -o=coverage.xml \
-f=ut_coverage_html_reporter  -o=coverage.html \
-f=ut_coveralls_reporter      -o=coverage.json \
-f=ut_sonar_test_reporter     -o=test_results.xml \
-f=ut_xunit_reporter          -o=xunit_test_results.xml \
-scc

status_line_regex="^[0-9]+ tests, ([0-9]+) failed, ([0-9]+) errored.*"

#cat coverage.xml
#cat test_results.xml

RC=$(cat test_results.log | grep -E "${status_line_regex}" | sed -re "s/${status_line_regex}/\1\2/")

exit $RC
