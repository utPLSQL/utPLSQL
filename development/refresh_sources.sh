#!/usr/bin/env bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. development/env.sh

# remove sub-direcotry containing master branch shallow copy
rm -rf ${UTPLSQL_DIR:-utPLSQL_latest_release}
# clone utPLSQL master branch from upstream into utPLSQL sub-directory of your project
git clone --depth=1 --branch=${SELFTESTING_BRANCH:-master} https://github.com/utPLSQL/utPLSQL.git ${UTPLSQL_DIR:-utPLSQL_latest_release}

rm -rf utPLSQL-cli/*
# download beta version of utPLSQL-cli
curl -Lk -o utPLSQL-cli.zip https://bintray.com/viniciusam/utPLSQL-cli/download_file?file_path=utPLSQL-cli-develop-test3.zip
# unzip utPLSQL-cli and remove the zip file
unzip utPLSQL-cli.zip && chmod u+x utPLSQL-cli/bin/utplsql && rm utPLSQL-cli.zip

