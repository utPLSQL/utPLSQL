#!/bin/bash

set -ev

cd source
#install core of utplsql
"$ORACLE_HOME/bin/sqlplus" $UT3_OWNER/$UT3_OWNER_PASSWORD @install.sql


cd ..
cd build
#do style check
"$ORACLE_HOME/bin/sqlplus" $UT3_OWNER/$UT3_OWNER_PASSWORD @utplsql_style_check.sql
