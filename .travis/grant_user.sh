#!/bin/bash

set -ev

cd source
#grant framework user
"$SQLCLI" -L -S sys/oracle@//$CONNECTION_STR AS SYSDBA <<SQL
@create_synonyms_and_grants_for_user.sql $UT3_OWNER $UT3_USER
SQL
