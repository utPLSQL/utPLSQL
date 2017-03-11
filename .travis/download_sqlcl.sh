#!/bin/bash
set -e

if [ ! -d $HOME/.cache/sqlcl ]; then
    .travis/download.sh -p sqlcl
    unzip -q $SQLCL_FILE
    bash mv sqlcl $HOME/.cache
    rm -f $SQLCL_FILE
fi;
