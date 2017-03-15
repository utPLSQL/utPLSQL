#!/bin/bash
set -e

SQLCL_FILE=sqlcl-4.2.0.16.355.0402-no-jre.zip
cd .travis

# Download if not present on cache dir.
if [ ! -f $CACHE_DIR/$SQLCL_FILE ]; then
    sh download.sh -p sqlcl
    mv $SQLCL_FILE $CACHE_DIR
fi;

# Install sqlcl.
unzip -q $CACHE_DIR/$SQLCL_FILE -d $HOME

# Check if it is installed correctly.
$SQLCLI -v
