#!/bin/bash

set -ev

cd old_tests

"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR <<SQL
@RunAll.sql
exit
SQL
