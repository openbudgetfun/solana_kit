#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/sync-workspace-dependency-versions.sh [--check|--write]

  --check  Validate that all workspace-internal dependencies use ^<package_version>
  --write  Rewrite mismatched workspace-internal dependencies to ^<package_version> (default)
EOF
}

mode="write"

case "${1:-}" in
  "" ) ;;
  --check ) mode="check" ;;
  --write ) mode="write" ;;
  -h|--help )
    usage
    exit 0
    ;;
  * )
    echo "Unknown argument: $1" >&2
    usage >&2
    exit 2
    ;;
esac

repo_root="$(git rev-parse --show-toplevel)"
root_pubspec="$repo_root/pubspec.yaml"

if [[ ! -f "$root_pubspec" ]]; then
  echo "Could not find workspace root pubspec: $root_pubspec" >&2
  exit 1
fi

python3 - "$mode" "$repo_root" "$root_pubspec" <<'PY'
from __future__ import annotations

import re
import sys
from pathlib import Path

mode = sys.argv[1]
repo_root = Path(sys.argv[2])
root_pubspec = Path(sys.argv[3])

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
    print(f'No workspace packages found in {root_pubspec}', file=sys.stderr)
    sys.exit(1)

workspace_pubspecs: list[Path] = []
package_versions: dict[str, str] = {}
for package_path in workspace_paths:
    pubspec_path = repo_root / package_path / 'pubspec.yaml'
    if not pubspec_path.is_file():
        print(f'Workspace package pubspec not found: {pubspec_path}', file=sys.stderr)
        sys.exit(1)

    workspace_pubspecs.append(pubspec_path)

    name = ''
    version = ''
    for line in pubspec_path.read_text().splitlines():
        if not name:
            match = re.match(r'^name:\s*(\S+)\s*$', line)
            if match:
                name = match.group(1).strip('"\'')
                continue
        if not version:
            match = re.match(r'^version:\s*(\S+)\s*$', line)
            if match:
                version = match.group(1).strip('"\'')
                continue
        if name and version:
            break

    if not name:
        print(f'Failed to parse package name from: {pubspec_path}', file=sys.stderr)
        sys.exit(1)

    if version:
        if name in package_versions:
            print(f'Duplicate workspace package name detected: {name}', file=sys.stderr)
            sys.exit(1)
        package_versions[name] = version

section_pattern = re.compile(r'^(\s*)(dependencies|dev_dependencies|dependency_overrides):\s*$')
indent_pattern = re.compile(r'^(\s*)')
dependency_pattern = re.compile(r'^(\s*)([A-Za-z0-9_]+):\s*(.*)$')
excluded_path_parts = {'.dart_tool', 'build', '.git'}

target_pubspecs = sorted(
    path
    for path in repo_root.rglob('pubspec.yaml')
    if path != root_pubspec and not any(part in excluded_path_parts for part in path.parts)
)

reports: list[str] = []
total_mismatches = 0
updated_files = 0

for pubspec_path in target_pubspecs:
    original_lines = pubspec_path.read_text().splitlines()
    output_lines: list[str] = []
    in_dependency_section = False
    dependency_section_indent = 0

    for line_number, line in enumerate(original_lines, start=1):
        section_match = section_pattern.match(line)
        if section_match:
            in_dependency_section = True
            dependency_section_indent = len(section_match.group(1))
            output_lines.append(line)
            continue

        if in_dependency_section:
            if re.match(r'^\s*$', line):
                output_lines.append(line)
                continue

            current_indent = len(indent_pattern.match(line).group(1))
            if current_indent <= dependency_section_indent:
                in_dependency_section = False
            else:
                dependency_match = dependency_pattern.match(line)
                if dependency_match:
                    dependency_indent, dependency_name, dependency_value = dependency_match.groups()
                    dependency_value = dependency_value.rstrip()
                    if dependency_name in package_versions and dependency_value:
                        expected_version = f'^{package_versions[dependency_name]}'
                        dependency_value_core = dependency_value
                        dependency_comment = ''
                        comment_index = dependency_value.find('#')
                        if comment_index >= 0:
                            dependency_comment = dependency_value[comment_index:]
                            dependency_value_core = dependency_value[:comment_index].rstrip()

                        if dependency_value_core != expected_version:
                            reports.append(
                                f'{pubspec_path}:{line_number} {dependency_name} expected '
                                f'{expected_version} but found {dependency_value}'
                            )
                            total_mismatches += 1
                            if mode == 'write':
                                line = (
                                    f'{dependency_indent}{dependency_name}: {expected_version}'
                                    + (f' {dependency_comment}' if dependency_comment else '')
                                )
                output_lines.append(line)
                continue

        output_lines.append(line)

    new_text = '\n'.join(output_lines) + '\n'
    old_text = pubspec_path.read_text()
    if mode == 'write' and new_text != old_text:
        pubspec_path.write_text(new_text)
        updated_files += 1

for report in reports:
    print(report)

if mode == 'check':
    if total_mismatches > 0:
        print(
            f'Found {total_mismatches} workspace dependency version mismatches.',
            file=sys.stderr,
        )
        sys.exit(1)
    print('All workspace dependency versions are aligned.')
    sys.exit(0)

if total_mismatches == 0:
    print('Workspace dependency versions are already aligned.')
    sys.exit(0)

print(
    f'Updated {updated_files} pubspecs; fixed '
    f'{total_mismatches} workspace dependency constraints.'
)
PY
