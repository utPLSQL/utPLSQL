#!/bin/bash

set -ev

cd tests
"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_PASSWORD @RunAll.sql
