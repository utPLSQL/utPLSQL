#!/bin/bash
set -e

clientDir=$(dirname $(readlink -f $0))
projectDir=$(pwd)

sqlplus /nolog @$clientDir/ut_run.sql '$clientDir' '$projectDir' $*
