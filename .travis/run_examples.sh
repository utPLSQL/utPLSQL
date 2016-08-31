#!/bin/bash

set -ev

cd examples
"$ORACLE_HOME/bin/sqlplus" $UT3_USER/$UT3_PASSWORD @RunAllExamplesAsTests.sql
