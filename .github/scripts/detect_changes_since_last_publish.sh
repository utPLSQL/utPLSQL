#!/usr/bin/env bash

# Detects what has changed since the last publish, so that builds of unchanged code
# (e.g. scheduled builds) do not produce new commits on develop and gh-pages branches.
#
# Outputs (written to $GITHUB_OUTPUT):
#   project_changed - true when there are new commits since the last project version update commit
#   docs_changed    - true when documentation sources changed since the last deployment of documentation to gh-pages

VERSION_COMMIT_MESSAGE='Updated project version after build [skip ci]'
DOCS_PATHS="docs mkdocs.yml"
DOCS_VERSION="develop"

if [[ "$(git log -1 --format=%s HEAD)" == "${VERSION_COMMIT_MESSAGE}" ]]; then
  echo "No new commits since last project version update."
  project_changed=false
else
  echo "New commits found since last project version update."
  project_changed=true
fi

# mike commits to gh-pages with message: "Deployed <sha> to <version> with MkDocs <x> and mike <y>"
git fetch --quiet origin gh-pages
last_deployed_sha=$(git log -1 --format=%s --grep="^Deployed [0-9a-f]* to ${DOCS_VERSION} with MkDocs" origin/gh-pages | sed -nE "s/^Deployed ([0-9a-f]+) to .*/\1/p")

if [[ -z "${last_deployed_sha}" ]] || ! git cat-file -e "${last_deployed_sha}^{commit}" 2>/dev/null; then
  echo "Commit of last '${DOCS_VERSION}' documentation deployment not found."
  docs_changed=true
elif git diff --quiet "${last_deployed_sha}" HEAD -- ${DOCS_PATHS}; then
  echo "No documentation changes since last '${DOCS_VERSION}' documentation deployment from commit ${last_deployed_sha}."
  docs_changed=false
else
  echo "Documentation changed since last '${DOCS_VERSION}' documentation deployment from commit ${last_deployed_sha}."
  docs_changed=true
fi

echo "project_changed=${project_changed}" >> $GITHUB_OUTPUT
echo "docs_changed=${docs_changed}" >> $GITHUB_OUTPUT
