#!/usr/bin/env bash

cd lib/any_data/sources
sqlplus $UT3_USER/$UT3_PASSWORD @install.sql
cd ../../..

