#!/bin/bash
set -e

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-toplevel)"

. development/env.sh

cd source

"${SQLCLI}" sys/${ORACLE_PWD}@//${CONNECTION_STR} AS SYSDBA @uninstall ${UT3_DEVELOP_SCHEMA}

# Same install steps as .github/scripts/install.sh, without recreating the user or public synonyms
"${SQLCLI}" sys/${ORACLE_PWD}@//${CONNECTION_STR} AS SYSDBA <<-SQL
whenever sqlerror exit failure rollback
alter session set plsql_optimize_level=0;
@install ${UT3_DEVELOP_SCHEMA}
@create_grants ${UT3_DEVELOP_SCHEMA} PUBLIC
@install_ddl_trigger ${UT3_DEVELOP_SCHEMA}
exit
SQL

# Reinstall dropped the grants on ${UT3_DEVELOP_SCHEMA} objects
../.github/scripts/create_test_grants.sh
