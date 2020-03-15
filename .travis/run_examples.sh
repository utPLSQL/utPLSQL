#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"/../examples

set -ev

"$SQLCLI" $UT3_DEVELOP_SCHEMA/$UT3_DEVELOP_SCHEMA_PASSWORD@//$CONNECTION_STR <<SQL
set echo on
set feedback on
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

@RunAllExamplesAsTests.sql

exit

SQL
