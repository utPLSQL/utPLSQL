#!/bin/bash

set -ev

cd tests
"$SQLCLI" $UT3_USER/$UT3_USER_PASSWORD@//$CONNECTION_STR @RunAll.sql
