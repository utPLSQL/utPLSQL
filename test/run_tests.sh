#!/bin/bash
set -ev

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

time utPLSQL-cli/bin/utplsql run UT3_TESTER_HELPER/ut3@${CONNECTION_STR} \
-source_path=source -owner=ut3_develop \
-p='ut3_tester,ut3_user' \
-test_path=test -c \
  -regex_expression="test/(\w+)(/(\w+))*/(\w+)\.(.{3})$" \
  -owner_subexpression=1 \
  -type_subexpression=5 \
  -name_subexpression=4 \
-f=ut_coverage_sonar_reporter     -o=coverage.xml \
-f=ut_coverage_cobertura_reporter -o=cobertura.xml \
-f=ut_coverage_html_reporter      -o=coverage.html \
-f=ut_coveralls_reporter          -o=coverage.json \
-f=ut_sonar_test_reporter         -o=test_results.xml \
-f=ut_junit_reporter              -o=junit_test_results.xml \
-f=ut_tfs_junit_reporter          -o=tfs_test_results.xml \
-f=ut_documentation_reporter      -o=test_results.log -s
