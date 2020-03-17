#!/usr/bin/env bash

export SQLCLI=sql # For sqlcl client
#export SQLCLI=sqlplus # For sqlplus client
export CONNECTION_STR=127.0.0.1:1521/xe # Adjust the connect string
export ORACLE_PWD=oracle # Adjust your local SYS password
export UTPLSQL_CLI_VERSION="3.1.6"
export SELFTESTING_BRANCH=develop

export UTPLSQL_DIR="utPLSQL_latest_release"
export UT3_DEVELOP_SCHEMA=UT3_DEVELOP
export UT3_DEVELOP_SCHEMA_PASSWORD=ut3
export UT3_RELEASE_VERSION_SCHEMA=UT3
export UT3_RELEASE_VERSION_SCHEMA_PASSWORD=ut3
export UT3_TESTER=UT3_TESTER
export UT3_TESTER_PASSWORD=ut3
export UT3_TESTER_HELPER=UT3_TESTER_HELPER
export UT3_TESTER_HELPER_PASSWORD=ut3
export UT3_TABLESPACE=users
export UT3_USER="UT3\$USER#"
export UT3_USER_PASSWORD=ut3
