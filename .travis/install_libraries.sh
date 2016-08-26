#!/usr/bin/env bash

work_dir="$(dirname "$(readlink -f "$0")")"
lib_dir=lib
#Create directory if it's not already there
[ -d lib ] || mkdir lib

# Install any_data into lib directory
any_data_version=1.0.4

. ${work_dir}/any_data_download.sh ${lib_dir} ${any_data_version}
. ${work_dir}/any_data_install.sh  ${lib_dir} ${any_data_version}
