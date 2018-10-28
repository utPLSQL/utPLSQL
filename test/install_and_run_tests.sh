#!/bin/bash
set -ev

check_result()
{
  RC1=$1
  RC2=$2

  if [ "$RC1" != "0" ] || [ "$RC2" != "0" ]; then
   return 1
  fi
  return 0
}

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

cd test

time "$SQLCLI" ${UT3_USER}/${UT3_USER_PASSWORD}@//${CONNECTION_STR} @install__min_usr_tests.sql

cd ..

time utPLSQL-cli/bin/utplsql run ${UT3_USER}/${UT3_USER_PASSWORD}@${CONNECTION_STR} \
-source_path=source -owner=ut3 \
-test_path=test -c \
-f=ut_documentation_reporter  -o=min_test_results.log -s \
-scc

status_line_regex="^[0-9]+ tests, ([0-9]+) failed, ([0-9]+) errored.*"

RC1=$(cat min_test_results.log | grep -E "${status_line_regex}" | sed -re "s/${status_line_regex}/\1\2/")

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

status_line_regex="^[0-9]+ tests, ([0-9]+) failed, ([0-9]+) errored.*"

#cat coverage.xml
#cat test_results.xml

RC2=$(cat test_results.log | grep -E "${status_line_regex}" | sed -re "s/${status_line_regex}/\1\2/")

check_result $RC1 $RC2
RC=$?

exit $RC
