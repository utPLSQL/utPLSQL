#!/usr/bin/env bash
set -ev
#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

cd old_tests

"$SQLCLI" ${UT3_OWNER}/${UT3_OWNER_PASSWORD}@//${CONNECTION_STR} @RunAll.sql
