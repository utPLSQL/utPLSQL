#!/bin/bash

cd "$(dirname "$(readlink -f "$0")")"/../examples

set -ev

"$SQLCLI" $UT3_DEVELOP_SCHEMA/$UT3_DEVELOP_SCHEMA_PASSWORD@//$CONNECTION_STR <<SQL

@RunAllExamplesAsTests.sql

exit

SQL
