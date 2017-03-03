#!/bin/bash
# Change working directory to script directory
cd "${0%/*}"
chmod +x ./update_version.sh
chmod +x ./build_docs.sh
chmod +x ./create_release_archive.sh

bash ./update_version.sh
bash ./build_docs.sh
bash ./create_release_archive.sh
