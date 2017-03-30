#!/bin/bash
# Change working directory to script directory
cd "${0%/*}"
# Change back to root
cd ..
mkdocs build --clean --strict

mkdir docs/markdown
mv -t docs/markdown/ docs/about docs/images docs/userguide docs/index.md
mkdir docs/html
cp -r -v site/* docs/html
