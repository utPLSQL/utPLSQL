#!/usr/bin/env bash
version=`cat VERSION`
#When on develop branch, add "-develop" to the version text
if [[ "${CI_ACTION_REF_NAME}" == "develop" ]]; then
    version=`sed -E "s/(v?[0-9]+\.[0-9]+\.[0-9]+).*/\1-develop/" <<< "${version}"`
fi
echo ${version}
