#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/sync-package-changelogs.sh [--check|--write]

  --check  Validate that all non-private workspace packages match root CHANGELOG.md
  --write  Copy root CHANGELOG.md into all non-private workspace packages (default)
USAGE
}

mode="${1:---write}"
if [[ "$mode" != "--check" && "$mode" != "--write" ]]; then
  usage >&2
  exit 2
fi

repo_root="$(git rev-parse --show-toplevel)"
root_pubspec="$repo_root/pubspec.yaml"
root_changelog="$repo_root/CHANGELOG.md"

if [[ ! -f "$root_pubspec" ]]; then
  echo "Missing workspace pubspec: $root_pubspec" >&2
  exit 2
fi

if [[ ! -f "$root_changelog" ]]; then
  echo "Missing root changelog: $root_changelog" >&2
  exit 2
fi

mapfile -t workspace_paths < <(
  awk '
    /^workspace:[[:space:]]*$/ { in_workspace = 1; next }
    in_workspace == 1 {
      if ($0 ~ /^[^[:space:]-][^:]*:[[:space:]]*$/) {
        in_workspace = 0
        next
      }
      if (match($0, /^[[:space:]]*-[[:space:]]*(.+)[[:space:]]*$/, m)) {
        print m[1]
      }
    }
  ' "$root_pubspec"
)

if [[ "${#workspace_paths[@]}" -eq 0 ]]; then
  echo "No workspace package paths found in $root_pubspec" >&2
  exit 2
fi

checked=0
updated=0
mismatches=0

is_private_pubspec() {
  local pubspec="$1"
  grep -Eq '^publish_to:[[:space:]]*["'"'"'"'"'"'"'"'"']?none["'"'"'"'"'"'"'"'"']?[[:space:]]*$' "$pubspec"
}

for package_path in "${workspace_paths[@]}"; do
  pubspec="$repo_root/$package_path/pubspec.yaml"
  changelog="$repo_root/$package_path/CHANGELOG.md"

  if [[ ! -f "$pubspec" ]]; then
    echo "Missing workspace package pubspec: $pubspec" >&2
    exit 2
  fi

  if is_private_pubspec "$pubspec"; then
    continue
  fi

  checked=$((checked + 1))

  if [[ ! -f "$changelog" ]] || ! cmp -s "$root_changelog" "$changelog"; then
    if [[ "$mode" == "--check" ]]; then
      echo "$changelog differs from root CHANGELOG.md"
      mismatches=$((mismatches + 1))
    else
      cp "$root_changelog" "$changelog"
      updated=$((updated + 1))
    fi
  fi
done

if [[ "$mode" == "--check" ]]; then
  if [[ "$mismatches" -gt 0 ]]; then
    echo "Found $mismatches mismatched changelog(s) across $checked non-private workspace packages." >&2
    exit 1
  fi
  echo "All $checked non-private workspace package changelogs match root CHANGELOG.md."
  exit 0
fi

if [[ "$updated" -eq 0 ]]; then
  echo "All $checked non-private workspace package changelogs already match root CHANGELOG.md."
else
  echo "Updated $updated changelog(s) across $checked non-private workspace packages."
fi
