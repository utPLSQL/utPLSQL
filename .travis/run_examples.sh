#!/bin/bash

set -ev

"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR <<SQL
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

cd examples
@RunAllExamplesAsTests.sql

exit

SQL