#!/bin/bash

set -ev

cd source
#grant framework user
"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
@create_synonyms_and_grants_for_user.sql $UT3_OWNER $UT3_USER
SQL
