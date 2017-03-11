#!/bin/bash

set -ev

cd source
#grant framework user
"$SQLCLI" -L -S sys/oracle@//oracle-12c-r1-se:1521/ORCLCDB AS SYSDBA <<SQL
@create_synonyms_and_grants_for_user.sql $UT3_OWNER $UT3_USER
SQL
