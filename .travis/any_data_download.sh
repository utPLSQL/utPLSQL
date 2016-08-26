#!/usr/bin/env bash

lib_dir=$1
version=$2

wget -O ${lib_dir}/v${version}.zip https://github.com/jgebal/any_data/archive/v${version}.zip
unzip ${lib_dir}/v${version}.zip -d ${lib_dir}
