#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

base_sha="${BASE_SHA:-}"
head_sha="${HEAD_SHA:-}"

if [[ -z "$base_sha" || -z "$head_sha" ]]; then
  if git rev-parse --verify --quiet origin/main >/dev/null; then
    base_sha="$(git merge-base origin/main HEAD)"
    head_sha="HEAD"
  else
    echo "BASE_SHA/HEAD_SHA are required when origin/main is unavailable." >&2
    exit 2
  fi
fi

changed_files="$(git diff --name-only "$base_sha...$head_sha")"

if [[ -z "$changed_files" ]]; then
  echo "No changed files detected."
  exit 0
fi

changeset_changes="$(printf '%s\n' "$changed_files" | grep '^\.changeset/.*\.md$' || true)"
if [[ -n "$changeset_changes" ]]; then
  changeset_args=()
  while IFS= read -r changeset_path; do
    [[ -n "$changeset_path" ]] && changeset_args+=("$changeset_path")
  done <<< "$changeset_changes"

  echo "Validating changed changeset frontmatter."
  scripts/check-changeset-frontmatter.sh "${changeset_args[@]}"
fi

package_changes="$(printf '%s\n' "$changed_files" | grep '^packages/' || true)"
if [[ -z "$package_changes" ]]; then
  echo "No package changes detected; changeset not required."
  exit 0
fi

if [[ -n "$changeset_changes" ]]; then
  echo "Changeset requirement satisfied."
  exit 0
fi

echo "Package changes were detected without a changeset file under .changeset/*.md." >&2
echo "Run 'knope document-change', then replace the frontmatter with 'default: patch|minor|major', and commit the changeset." >&2
echo "Changed package files:" >&2
printf '%s\n' "$package_changes" >&2
exit 1
