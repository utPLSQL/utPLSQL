#!/bin/bash

set -ev

cd test

"$ORACLE_HOME/bin/sqlplus" -L -S utp/utp <<SQL
@utPLSQL_selftest.sql
exit
SQL

