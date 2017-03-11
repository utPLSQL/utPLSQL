#!/bin/bash

set -ev

cd tests
"$SQLCLI" $UT3_USER/$UT3_USER_PASSWORD@//$CONTAINER_IP:1521/ORCLCDB @RunAll.sql
