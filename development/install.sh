#!/usr/bin/env bash

cd $(git rev-parse --show-cdup)

development/env.sh
development/cleanup.sh
.travis/install.sh
.travis/install_utplsql_release.sh
.travis/create_additional_grants_for_old_tests.sh
