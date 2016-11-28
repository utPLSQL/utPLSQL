#!/bin/bash
set -ev

#create user
"$ORACLE_HOME/bin/sqlplus" -L -S / AS SYSDBA <<SQL
set echo off
@@$(dirname "$(readlink -f "$0")")/create_utplsql_user.sql $UT3_USER $UT3_USER_PASSWORD $UT3_USER_TABLESPACE
SQL
#give grants
"$ORACLE_HOME/bin/sqlplus" -L -S $UT3_OWNER/$UT3_OWNER_PASSWORD <<SQL
set echo off
@@$(dirname "$(readlink -f "$0")")/utplsql_grants.sql $UT3_USER 
SQL
# create synonyms
"$ORACLE_HOME/bin/sqlplus" -L -S / as sysdba <<SQL
set echo off
@@$(dirname "$(readlink -f "$0")")/utplsql_grants.sql $UT3_OWNER "$UT3_USER." ""
SQL
