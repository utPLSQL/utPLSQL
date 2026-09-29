#!/usr/bin/env bash

# Updates version badge in documentation files.
# Usage: .github/scripts/update_docs_version.sh <version>
#   e.g. .github/scripts/update_docs_version.sh v3.2.4.4600

docs_version=$1
[[ -n "${docs_version}" ]] || { echo "Documentation version not provided"; exit 1; }

# "-" needs to be escaped as "--" in shields.io badge
find docs -type f -name '*.md' -exec sed -i -r "s/(badge\/version-).*(-blue\.svg)/\1${docs_version//-/--}\2/" {} \;
echo Documentation files updated with version: ${docs_version}
