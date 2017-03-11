#!/bin/bash
set -e

if [ ! $HOME/.cache/$SQLCL_FILE ]; then
    .travis/download.sh -p sqlcl
    unzip -q $SQLCL_FILE
    bash mv sqlcl $HOME/.cache
    rm -f $SQLCL_FILE
fi;
