#!/bin/bash

set -ev

cd source
#install core of utplsql
"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_PASSWORD @install.sql
