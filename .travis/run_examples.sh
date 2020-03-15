#!/bin/bash

set -ev

"$SQLCLI" $UT3_DEVELOP_SCHEMA/$UT3_DEVELOP_SCHEMA_PASSWORD@//$CONNECTION_STR <<SQL
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

cd examples
@RunAllExamplesAsTests.sql

exit

SQL