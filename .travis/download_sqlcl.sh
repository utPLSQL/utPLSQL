#!/bin/bash
set -e

cd .travis
if [ ! -d $HOME/.cache/sqlcl ]; then
    sh download.sh -p sqlcl
    unzip -q sqlcl-4.2.0.16.355.0402-no-jre.zip
    rm -f sqlcl-4.2.0.16.355.0402-no-jre.zip
    mv sqlcl $HOME/.cache/
fi;
