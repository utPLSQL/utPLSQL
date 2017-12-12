#!/usr/bin/env bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. development/env.sh

# remove sub-direcotry containing master branch shallow copy
rm -rf ${UTPLSQL_DIR:-utPLSQL_latest_release}
# clone utPLSQL master branch from upstream into utPLSQL sub-directory of your project
git clone --depth=1 --branch=${SELFTESTING_BRANCH:-master} https://github.com/utPLSQL/utPLSQL.git ${UTPLSQL_DIR:-utPLSQL_latest_release}

# download latest release version of utPLSQL-cli
curl -LOk $(curl --silent https://api.github.com/repos/utPLSQL/utPLSQL-cli/releases/latest | awk '/browser_download_url/ { print $2 }' | grep ".zip" | sed 's/"//g')
# unzip utPLSQL-cli and remove the zip file
unzip -o utPLSQL-cli.zip && chmod u+x utPLSQL-cli/bin/utplsql && rm utPLSQL-cli.zip

