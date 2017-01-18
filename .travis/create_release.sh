#!/bin/bash
# Change working directory to script directory
cd "${0%/*}"
chmod +x ./build_docs.sh
chmod +x ./create_release_archive.sh
./build_docs.sh
./create_release_archive.sh