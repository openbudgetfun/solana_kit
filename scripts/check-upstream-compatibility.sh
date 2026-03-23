#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

clone_if_missing=false
if [[ "${1:-}" == "--clone-if-missing" ]]; then
  clone_if_missing=true
fi

upstream_dir="$repo_root/.repos/kit"
upstream_package_json="$upstream_dir/packages/kit/package.json"

extract_first_semver() {
  local file="$1"
  local pattern="$2"

  local match
  match="$(rg -o "$pattern" "$file" | head -n 1 || true)"
  if [[ -z "$match" ]]; then
    return 1
  fi

  printf '%s\n' "$match" | rg -o '[0-9]+\.[0-9]+\.[0-9]+'
}

tracked_version="$(extract_first_semver \
  "readme.md" \
  'Latest supported `@solana/kit` version: `[0-9]+\.[0-9]+\.[0-9]+`')"

if [[ -z "$tracked_version" ]]; then
  echo "Failed to determine the tracked @solana/kit version from readme.md." >&2
  exit 1
fi

version_files=(
  "readme.md"
  "packages/solana_kit/README.md"
  "docs/site/content/index.md"
  "docs/site/content/reference/upstream-compatibility.md"
)

failed=0

for file in "${version_files[@]}"; do
  latest_supported="$(extract_first_semver \
    "$file" \
    'Latest supported `@solana/kit` version: `[0-9]+\.[0-9]+\.[0-9]+`' || true)"
  tracked_behavior="$(extract_first_semver \
    "$file" \
    'tracks upstream APIs and behavior through `v[0-9]+\.[0-9]+\.[0-9]+`' || true)"

  if [[ -z "$latest_supported" || -z "$tracked_behavior" ]]; then
    echo "Missing upstream compatibility metadata in $file" >&2
    failed=1
    continue
  fi

  if [[ "$latest_supported" != "$tracked_version" ]]; then
    echo "Tracked version mismatch in $file: expected $tracked_version, found $latest_supported" >&2
    failed=1
  fi

  if [[ "$tracked_behavior" != "$tracked_version" ]]; then
    echo "Behavior version mismatch in $file: expected $tracked_version, found $tracked_behavior" >&2
    failed=1
  fi

done

if [[ "$clone_if_missing" == true && ! -d "$upstream_dir" ]]; then
  echo "Cloning upstream @solana/kit into $upstream_dir"
  mkdir -p "$(dirname "$upstream_dir")"
  git clone --depth 1 https://github.com/anza-xyz/kit "$upstream_dir"
fi

if [[ -f "$upstream_package_json" ]]; then
  upstream_version="$(extract_first_semver \
    "$upstream_package_json" \
    '"version": "[0-9]+\.[0-9]+\.[0-9]+"' || true)"

  if [[ -n "$upstream_version" && "$upstream_version" != "$tracked_version" ]]; then
    echo "NOTICE: upstream @solana/kit is currently $upstream_version while this workspace tracks $tracked_version." >&2
    echo "NOTICE: update docs and parity work intentionally; do not silently bump compatibility claims." >&2
  fi
else
  echo "NOTICE: skipping upstream repo drift check because $upstream_package_json is unavailable." >&2
  echo "NOTICE: run clone:repos or scripts/check-upstream-compatibility.sh --clone-if-missing." >&2
fi

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

echo "Upstream compatibility metadata is internally consistent for tracked version $tracked_version."
