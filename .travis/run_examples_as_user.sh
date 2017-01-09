#!/bin/bash

set -ev

cd examples
"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_USER_PASSWORD <<SQL
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

@RunUserExamples.sql

exit success
SQL
