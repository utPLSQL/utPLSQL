#!/bin/bash
# Publishes a release announcement post to utplsql.github.io.
# Creates the post file, prepends an entry to docs/index.md,
# and inserts the post into the mkdocs.yml nav.
#
# Required environment variables:
#   API_TOKEN_GITHUB - GitHub token with write access to utPLSQL.github.io
#   RELEASE_TAG      - e.g. v3.2.01
#   RELEASE_BODY     - markdown release notes (from github.event.release.body)
#   RELEASE_DATE     - ISO-8601 publish timestamp (from github.event.release.published_at)

set -euo pipefail

GITHUB_IO_REPO="utPLSQL/utPLSQL.github.io"
GITHUB_IO_BRANCH="main"

VERSION="${RELEASE_TAG#v}"
POST_DATE=$(echo "${RELEASE_DATE}" | cut -c1-10)
POST_TIME=$(echo "${RELEASE_DATE}" | sed 's/T/ /' | sed 's/Z/ +0000/')
POST_FILENAME="${POST_DATE}-version${VERSION}-released.md"
POST_TITLE="utPLSQL ${RELEASE_TAG} released"
POST_NAV_TITLE="utPLSQL ${VERSION} released"

mkdir -p github_io
cd github_io
git clone --depth 1 "https://${API_TOKEN_GITHUB}@github.com/${GITHUB_IO_REPO}" -b "${GITHUB_IO_BRANCH}" .

# Format the release body for the post:
#   1. Convert bare GitHub issue/PR URLs to [#NUMBER](URL)
#      e.g.  https://github.com/utPLSQL/utPLSQL/pull/1320
#         -> [#1320](https://github.com/utPLSQL/utPLSQL/pull/1320)
#   2. Convert the auto-generated "Full Changelog" bare URL to a labelled link
#      e.g.  **Full Changelog**: https://.../compare/v3.2.01...v3.2.2
#         -> **Full Changelog**: [v3.2.01...v3.2.2](https://.../compare/v3.2.01...v3.2.2)
FORMATTED_BODY=$(echo "${RELEASE_BODY}" \
  | sed -E 's@https://github\.com/([^/]+)/([^/]+)/(pull|issues)/([0-9]+)@[#\4](https://github.com/\1/\2/\3/\4)@g' \
  | sed -E 's@\*\*Full Changelog\*\*: (https://[^ ]+/compare/([^ ]+))@\*\*Full Changelog\*\*: [\2](\1)@g')

# Create the post file
cat > "docs/_posts/${POST_FILENAME}" <<POSTEOF
---
layout: post
title:  "${POST_TITLE}"
date:   ${POST_TIME}
categories: version3
---

${FORMATTED_BODY}

----------------------------
[Download utPLSQL release ${RELEASE_TAG} here](https://github.com/utPLSQL/utPLSQL/releases/tag/${RELEASE_TAG})
POSTEOF

# Prepend new entry to the top of docs/index.md
INDEX_ENTRY="----------------------------------------------------------------------

^${POST_DATE}^

[${POST_TITLE}](_posts/${POST_FILENAME})

----------------------------------------------------------------------

"
printf '%s' "${INDEX_ENTRY}" | cat - docs/index.md > /tmp/index_new.md
mv /tmp/index_new.md docs/index.md

# Insert new post into mkdocs.yml nav immediately after "- index.md"
sed -i "s|    - index.md|    - index.md\n    - ${POST_NAV_TITLE}: _posts/${POST_FILENAME}|" mkdocs.yml

git add "docs/_posts/${POST_FILENAME}" docs/index.md mkdocs.yml
git commit -m "Release announcement for ${RELEASE_TAG}"
git push origin "${GITHUB_IO_BRANCH}"

echo "Release post published: docs/_posts/${POST_FILENAME}"
