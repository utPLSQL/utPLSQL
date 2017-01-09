#!/bin/bash

set -ev

cd client_source
#grant framework user
"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
@grant_user.sql $UT3_OWNER $UT3_USER
SQL