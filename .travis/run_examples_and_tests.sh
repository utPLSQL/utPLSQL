#!/bin/bash

set -ev

"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR <<SQL
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

cd examples
@RunAllExamplesAsTests.sql

conn $UT3_USER/$UT3_USER_PASSWORD@//$CONNECTION_STR
@RunUserExamples.sql

exit

SQL

"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR <<SQL
cd tests
@RunAll.sql
exit
SQL
