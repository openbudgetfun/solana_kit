#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

"$repo_root/scripts/check-upstream-compatibility.sh" "$@"

if ! command -v node >/dev/null 2>&1; then
  echo "node is required for upstream parity checks." >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required for upstream parity checks." >&2
  exit 1
fi

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

cache_dir="$repo_root/.dart_tool/upstream-kit-node"
fixtures_dir="$repo_root/.dart_tool/upstream-parity"
fixtures_json="$fixtures_dir/fixtures.json"
installed_package_json="$cache_dir/node_modules/@solana/kit/package.json"

installed_version=""
if [[ -f "$installed_package_json" ]]; then
  installed_version="$(python3 - <<'PY' "$installed_package_json"
import json
import pathlib
import sys
print(json.loads(pathlib.Path(sys.argv[1]).read_text()).get('version', ''))
PY
)"
fi

if [[ "$installed_version" != "$tracked_version" ]]; then
  echo "Preparing upstream @solana/kit@$tracked_version runtime fixture environment..."
  rm -rf "$cache_dir"
  mkdir -p "$cache_dir"
  cat > "$cache_dir/package.json" <<EOF
{
  "private": true,
  "type": "module",
  "dependencies": {
    "@solana/kit": "$tracked_version"
  }
}
EOF
  (
    cd "$cache_dir"
    npm install --ignore-scripts --no-audit --no-fund --silent
  )
fi

mkdir -p "$fixtures_dir"
UPSTREAM_KIT_NODE_MODULES="$cache_dir/node_modules" \
  node "$repo_root/scripts/generate-upstream-parity-fixtures.mjs" > "$fixtures_json"

echo "Generated upstream parity fixtures at $fixtures_json"
UPSTREAM_PARITY_FIXTURES_JSON="$fixtures_json" \
  dart test packages/solana_kit/test/upstream_parity_test.dart

echo "Upstream parity checks passed against @solana/kit@$tracked_version."
