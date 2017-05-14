#!/bin/bash
# Change working directory to script directory
cd "${0%/*}"
# Change back to root
cd ..
mkdocs build --clean --strict
