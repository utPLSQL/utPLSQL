#!/bin/bash
set -ev
#replace "/" with "@"
conn_str=${CONNECTION_STR//\//@}

"$SQLCLI" ${UT3_TESTER}/${UT3_TESTER_PASSWORD}@//${CONNECTION_STR} <<-SQL
@ut_utils/test_ut_utils.pks
@ut_utils/test_ut_utils.pkb
exit
SQL

utPLSQL-cli/bin/utplsql run ${UT3_TESTER}/${UT3_TESTER_PASSWORD}${conn_str} \
-source_path=source -test_path=tests \
-f=ut_documentation_reporter  -c \
-f=ut_coverage_sonar_reporter -o=coverage.xml \
-f=ut_sonar_test_reporter     -o=test_results.xml
