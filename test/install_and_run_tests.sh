#!/bin/bash
set -ev

#cd test
#
#"$SQLCLI" ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@//${CONNECTION_STR} @install_tests.sql
#
#cd ..
#
#utPLSQL-cli/bin/utplsql run ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@${CONNECTION_STR} \
#-source_path=source -test_path=tests \
#-f=ut_documentation_reporter  -c -o=test_results.log -s \
#-f=ut_coverage_sonar_reporter -o=coverage.xml \
#-f=ut_sonar_test_reporter     -o=test_results.xml

status_line_regex="^[0-9]+ tests, ([0-9]+) failed, ([0-9]+) errored.*"

RC=$(cat test_results.log | grep -E "${status_line_regex}" | sed -re "s/${status_line_regex}/\1\2/")

exit $RC
