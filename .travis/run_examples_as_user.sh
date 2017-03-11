#!/bin/bash

set -ev

cd examples
"$SQLCLI" $UT3_USER/$UT3_USER_PASSWORD@//$CONTAINER_IP:1521/ORCLCDB <<SQL
whenever sqlerror exit failure rollback
whenever oserror exit failure rollback

@RunUserExamples.sql

exit success
SQL
