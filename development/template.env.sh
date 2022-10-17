#!/bin/bash

export SQLCLI=sql # For sqlcl client
#export SQLCLI=sqlplus # For sqlplus client
export CONNECTION_STR=127.0.0.1:1521/xe         ORACLE_VERSION=11g-r2-xe# Adjust the connect string
export ORACLE_PWD=oracle # Adjust your local SYS password
export UTPLSQL_CLI_VERSION="3.1.6"
export SELFTESTING_BRANCH=develop

export UTPLSQL_DIR="utPLSQL_latest_release"
export UT3_DEVELOP_SCHEMA=UT3_DEVELOP
export UT3_DEVELOP_SCHEMA_PASSWORD=ut3
export UT3_RELEASE_VERSION_SCHEMA=UT3
export UT3_RELEASE_VERSION_SCHEMA_PASSWORD=ut3
export UT3_TABLESPACE=users
