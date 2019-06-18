#!/usr/bin/env bash

export SQLCLI=sql # For sqlcl client
#export SQLCLI=sqlplus # For sqlplus client
export CONNECTION_STR=127.0.0.1:1521/xe # Adjust the connect string
export ORACLE_PWD=oracle # Adjust your local SYS password
export UTPLSQL_CLI_VERSION="3.1.6"
export SELFTESTING_BRANCH=develop

export UTPLSQL_DIR="utPLSQL_latest_release"
export UT3_OWNER=ut3
export UT3_OWNER_PASSWORD=ut3
export UT3_RELEASE_VERSION_SCHEMA=ut3_latest_release
export UT3_TESTER=ut3_tester
export UT3_TESTER_PASSWORD=ut3
export UT3_TESTER_HELPER=ut3_tester_helper
export UT3_TESTER_HELPER_PASSWORD=ut3
export UT3_TABLESPACE=users
export UT3_USER="UT3\$USER#"
export UT3_USER_PASSWORD=ut3
