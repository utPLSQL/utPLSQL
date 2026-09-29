#!/usr/bin/env bash

# Returns the version shown on the badge of documentation, as originally published for a release.
# Used when rebuilding documentation of older releases, so that the rebuild does not alter version badges.
# Usage: .github/scripts/get_published_docs_version.sh <release tag>
#
# Version is taken from the first deployment of the release documentation to gh-pages.
# If not found, it is derived from the release tag and BUILD_NO file, the same way as done by release process.
# Returns nothing if version cannot be determined.

version=$1
[[ -n "${version}" ]] || { echo "Release tag not provided" >&2; exit 1; }

# mike commits to gh-pages with message: "Deployed <sha> to <version> with MkDocs <x> and mike <y>"
first_deployment=$(git log origin/gh-pages --format=%H -F --grep=" to ${version} with MkDocs" | tail -1)
if [[ -n "${first_deployment}" ]]; then
  docs_version=$(git show "${first_deployment}:${version}/index.html" 2>/dev/null | sed -nE 's/.*img\.shields\.io\/badge\/version-([^"]*)-blue\.svg.*/\1/p' | head -1)
  # "-" is escaped as "--" in shields.io badge
  docs_version=${docs_version//--/-}
fi

if [[ -z "${docs_version}" ]]; then
  build_no=$(git show "tags/${version}:BUILD_NO" 2>/dev/null | tr -d '[:space:]')
  if [[ -n "${build_no}" ]]; then
    docs_version=$(echo ${version} | sed -E "s/(v?[0-9]+\.)([0-9]+\.)([0-9]+)(-.*)?/\1\2\3\.${build_no}\4/")
  fi
fi

echo ${docs_version}
