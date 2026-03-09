#!/bin/bash
set -ev

. ./development/env.sh

#goto git root directory
git rev-parse && cd "$(git rev-parse --show-cdup)"
cd test

time . ./install_tests.sh
time . ./run_tests.sh
