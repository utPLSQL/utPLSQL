#!/usr/bin/env bash

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"

. development/env.sh

development/cleanup.sh

.travis/install.sh
.travis/install_utplsql_release.sh
.travis/create_additional_grants_for_old_tests.sh
