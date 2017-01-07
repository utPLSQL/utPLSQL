#!/bin/bash

set -ev

cd source
#install core of utplsql
"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_PASSWORD @install.sql


cd ..
cd build
#do style check
"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_PASSWORD @utplsql_style_check.sql

#enable plsql debug
#"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_PASSWORD @ut_debug_enable.sql
