#!/usr/bin/env bash

lib_dir=$1
version=$2

cd ${lib_dir}/any_data-${version}/sources
sqlplus $UT3_USER/$UT3_PASSWORD @install.sql
cd ../../..

