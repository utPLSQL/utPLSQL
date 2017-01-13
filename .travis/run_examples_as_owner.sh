#!/bin/bash

set -ev

cd examples
"$ORACLE_HOME/bin/sqlplus" $UT3_OWNER/$UT3_OWNER_PASSWORD @RunAllExamplesAsTests.sql
