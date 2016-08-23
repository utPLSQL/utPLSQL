#!/bin/bash

set -ev

cd tests
"$ORACLE_HOME/bin/sqlplus" ut3/ut3 @RunAll.sql
