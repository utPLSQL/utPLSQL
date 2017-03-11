#!/bin/bash

set -ev

cd source
#install core of utplsql
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONTAINER_IP:1521/ORCLCDB @install.sql $UT3_OWNER


cd ..
cd development
#do style check
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONTAINER_IP:1521/ORCLCDB @utplsql_style_check.sql

#enable plsql debug
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONTAINER_IP:1521/ORCLCDB @ut_debug_enable.sql
