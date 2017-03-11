#!/bin/bash

set -ev

cd tests
"$SQLCLI" $UT3_OWNER/$UT3_OWNER_PASSWORD@//$CONTAINER_IP:1521/ORCLCDB @RunAll.sql
