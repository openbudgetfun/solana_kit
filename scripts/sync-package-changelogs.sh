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

python3 - "$mode" "$repo_root" "$root_pubspec" "$root_changelog" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

mode = sys.argv[1]
repo_root = Path(sys.argv[2])
root_pubspec = Path(sys.argv[3])
root_changelog = Path(sys.argv[4])

workspace_paths: list[str] = []
in_workspace = False
for line in root_pubspec.read_text().splitlines():
    if re.match(r'^workspace:\s*$', line):
        in_workspace = True
        continue
    if in_workspace:
        if line and not line.startswith(' ') and not line.startswith('-'):
            break
        match = re.match(r'^\s*-\s*(.+?)\s*$', line)
        if match:
            workspace_paths.append(match.group(1))

if not workspace_paths:
    print(f'No workspace package paths found in {root_pubspec}', file=sys.stderr)
    sys.exit(2)

root_changelog_text = root_changelog.read_text()
checked = 0
updated = 0
mismatches = 0

for package_path in workspace_paths:
    pubspec = repo_root / package_path / 'pubspec.yaml'
    changelog = repo_root / package_path / 'CHANGELOG.md'

    if not pubspec.is_file():
        print(f'Missing workspace package pubspec: {pubspec}', file=sys.stderr)
        sys.exit(2)

    pubspec_text = pubspec.read_text()
    if re.search(r'^publish_to:\s*["\']?none["\']?\s*$', pubspec_text, re.MULTILINE):
        continue

    checked += 1
    differs = (not changelog.exists()) or changelog.read_text() != root_changelog_text

    if not differs:
        continue

    if mode == '--check':
        print(f'{changelog} differs from root CHANGELOG.md')
        mismatches += 1
    else:
        changelog.write_text(root_changelog_text)
        updated += 1

if mode == '--check':
    if mismatches > 0:
        print(
            f'Found {mismatches} mismatched changelog(s) across '
            f'{checked} non-private workspace packages.',
            file=sys.stderr,
        )
        sys.exit(1)
    print(f'All {checked} non-private workspace package changelogs match root CHANGELOG.md.')
    sys.exit(0)

if updated == 0:
    print(f'All {checked} non-private workspace package changelogs already match root CHANGELOG.md.')
else:
    print(f'Updated {updated} changelog(s) across {checked} non-private workspace packages.')
PY
