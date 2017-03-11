#!/bin/bash

set -ev

cd examples
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD @RunAllExamplesAsTests.sql
