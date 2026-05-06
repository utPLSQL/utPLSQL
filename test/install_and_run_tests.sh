#!/bin/bash
set -ev

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"
. ./development/env.sh
cd test

time . ./install_tests.sh
time . ./run_tests.sh
