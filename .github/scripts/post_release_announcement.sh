#!/bin/bash
# Posts a release announcement to the utPLSQL org .github repository's
# Announcements discussion category.
#
# Required environment variables:
#   GH_TOKEN     - GitHub token with write:discussion scope (ORG_DISCUSSION_TOKEN)
#   RELEASE_TAG  - e.g. v3.2.3
#   RELEASE_BODY - markdown release notes
#   RELEASE_URL  - URL of the GitHub release page

set -euo pipefail

ORG="utPLSQL"
REPO_NAME=".github"

# Get org node ID
ORG_DATA=$(gh api graphql -f query='query($org: String!) {
  organization(login: $org) {
    id
  }
}' -f org="$ORG")
ORG_ID=$(echo "$ORG_DATA" | jq -r '.data.organization.id')

# Get repository node ID
REPO_DATA=$(gh api graphql -f query='query($owner: String!, $name: String!) {
  repository(owner: $owner, name: $name) {
    id
  }
}' -f owner="$ORG" -f name="$REPO_NAME")
REPO_ID=$(echo "$REPO_DATA" | jq -r '.data.repository.id')

# Get Announcements category ID
CATEGORY_DATA=$(gh api graphql -f query='query($owner: String!, $name: String!) {
  repository(owner: $owner, name: $name) {
    discussionCategories(first: 20) {
      nodes { id name }
    }
  }
}' -f owner="$ORG" -f name="$REPO_NAME")
CATEGORY_ID=$(echo "$CATEGORY_DATA" | jq -r \
  '.data.repository.discussionCategories.nodes[] | select(.name == "Announcements") | .id')

BODY="${RELEASE_BODY}

<hr /><em>This discussion was created from the release <a href='${RELEASE_URL}'>${RELEASE_TAG}</a>.</em>"

DISCUSSION_URL=$(gh api graphql -f query='mutation($repoId: ID!, $categoryId: ID!, $title: String!, $body: String!) {
  createDiscussion(input: {
    repositoryId: $repoId,
    categoryId: $categoryId,
    title: $title,
    body: $body
  }) {
    discussion { url }
  }
}' \
  -f repoId="$REPO_ID" \
  -f categoryId="$CATEGORY_ID" \
  -f title="utPLSQL ${RELEASE_TAG} released" \
  -f body="$BODY" \
  --jq '.data.createDiscussion.discussion.url')

echo "Announcement posted: $DISCUSSION_URL"
