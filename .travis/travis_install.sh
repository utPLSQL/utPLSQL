#!/bin/bash

set -ev

cd source

"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
@create_utp_user.sql
exit
SQL

"$ORACLE_HOME/bin/sqlplus" -L -S utp/utp <<SQL
@ut_i_do install
exit
SQL

