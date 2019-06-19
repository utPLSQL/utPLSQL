#!/bin/bash
set -ev

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"
cd test

time . ./${DIR}/install_tests.sh
time . ./${DIR}/run_tests.sh
