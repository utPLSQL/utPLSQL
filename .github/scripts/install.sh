#!/bin/bash

set -ev
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${SCRIPT_DIR}/../../source

INSTALL_FILE="install_headless_with_trigger.sql"
if [[ ! -f "${INSTALL_FILE}" ]]; then
 INSTALL_FILE="install_headless.sql"
fi

#install core of utplsql
time "$SQLCLI" sys/$ORACLE_PWD@//$CONNECTION_STR AS SYSDBA <<-SQL
whenever sqlerror exit failure rollback
set feedback off
set verify off

--alter session set plsql_warnings = 'ENABLE:ALL', 'DISABLE:(5004,5018,6000,6001,6003,6009,6010,7206)';
alter session set plsql_optimize_level=0;
@${INSTALL_FILE} $UT3_DEVELOP_SCHEMA $UT3_DEVELOP_SCHEMA_PASSWORD
SQL
