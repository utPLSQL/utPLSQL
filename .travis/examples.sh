#!/bin/bash

set -ev

cd examples
"$ORACLE_HOME/bin/sqlplus" ut3/ut3 @RunAllExamplesAsTests.sql
