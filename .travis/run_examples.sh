#!/bin/bash

set -ev
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}/../examples

"$SQLCLI" $UT3_DEVELOP_SCHEMA/$UT3_DEVELOP_SCHEMA_PASSWORD@//$CONNECTION_STR <<SQL

@RunAllExamplesAsTests.sql

exit

SQL
