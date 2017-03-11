#!/bin/bash
set -e

cd .travis
if [ ! -d $HOME/.cache/sqlcl ]; then
    download.sh -p sqlcl
    unzip -q $SQLCL_FILE
    bash mv sqlcl $HOME/.cache
    rm -f $SQLCL_FILE
fi;
