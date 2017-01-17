#!/bin/bash
# Change working directory to script directory
cd "${0%/*}"
./build_docs.sh
./create_release_archive.sh