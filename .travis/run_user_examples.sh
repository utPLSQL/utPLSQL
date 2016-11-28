#!/bin/bash

set -ev

cd examples
"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_USER_PASSWORD @RunAllExamplesAsTests.sql
