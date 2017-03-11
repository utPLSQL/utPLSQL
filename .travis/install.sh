#!/bin/bash

set -ev

cd source
#install core of utplsql
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD @install.sql $UT3_OWNER


cd ..
cd development
#do style check
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD @utplsql_style_check.sql

#enable plsql debug
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD @ut_debug_enable.sql
