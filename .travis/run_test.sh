#!/bin/bash

set -ev

cd tests
"$ORACLE_HOME/bin/sqlplus" $UT3_OWNER/$UT3_OWNER_PASSWORD @RunAll.sql $UT3_OWNER $UT3_OWNER_PASSWORD
