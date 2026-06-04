#!/bin/bash
# Updates CHANGELOG.md by prepending a new section for the release.
#
# Required environment variables:
#   RELEASE_TAG    - e.g. v3.2.3
#   RELEASE_BODY   - markdown release notes
#   RELEASE_DATE   - ISO-8601 date string (only the first 10 chars are used)
#   TARGET_BRANCH  - branch to push the updated changelog to

set -euo pipefail

python3 - <<'PYEOF'
import os

tag  = os.environ['RELEASE_TAG']
body = os.environ['RELEASE_BODY'].strip()
date = os.environ['RELEASE_DATE'][:10]

new_section = f"## [{tag}] - {date}\n\n{body}\n\n---\n\n"

with open('CHANGELOG.md', 'r') as f:
    content = f.read()

marker = '\n---\n'
pos = content.index(marker) + len(marker)
updated = content[:pos] + '\n' + new_section + content[pos:]

with open('CHANGELOG.md', 'w') as f:
    f.write(updated)

print(f"Added {tag} to CHANGELOG.md")
PYEOF

git add CHANGELOG.md
git commit -m "Add release notes for ${RELEASE_TAG} to CHANGELOG.md [skip ci]"
git push origin HEAD:"${TARGET_BRANCH}"
