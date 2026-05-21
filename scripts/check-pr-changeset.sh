#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [ -z "$(git diff --name-only --diff-filter=d HEAD^ -- '.changeset/*.md')" ]; then
    echo "No changeset files changed in this PR."
    exit 0
fi

CHANGED_FILES=$(git diff --name-only --diff-filter=d HEAD^ -- '.changeset/*.md')
./scripts/check-changeset-frontmatter.sh $CHANGED_FILES
