#!/bin/bash

set -ev

"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR <<SQL
cd tests
@RunAll.sql
exit
SQL
