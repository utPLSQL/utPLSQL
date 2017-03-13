#!/bin/bash

set -ev

cd source
#install core of utplsql
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR @install.sql $UT3_OWNER


cd ..
cd development
#do style check
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR @utplsql_style_check.sql

#enable plsql debug
#"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONNECTION_STR @ut_debug_enable.sql
