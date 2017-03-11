#!/bin/bash

set -ev

cd tests
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD @RunAll.sql
