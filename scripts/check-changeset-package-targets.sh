#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

python3 - "$@" <<'PY'
from pathlib import Path
import re
import sys

paths = [Path(arg) for arg in sys.argv[1:]]
if not paths:
    paths = sorted(Path('.changeset').glob('*.md'))

entry_re = re.compile(r'^"?(?P<target>[A-Za-z0-9_-]+)"?\s*:\s*(?P<bump>patch|minor|major)\s*$')
errors: list[str] = []

for path in paths:
    if path.suffix != '.md' or not str(path).startswith('.changeset/'):
        continue
    if not path.exists():
        continue

    lines = path.read_text(encoding='utf-8').splitlines()
    if not lines or lines[0].strip() != '---':
        continue

    closing_index = None
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == '---':
            closing_index = index
            break
    if closing_index is None:
        continue

    entries = [line.strip() for line in lines[1:closing_index] if line.strip()]
    for entry in entries:
        match = entry_re.match(entry)
        if not match:
            continue
        if match.group('target') == 'main':
            errors.append(
                f'{path}: targets the `main` release group. Target the granular package ids instead.'
            )

if errors:
    print('Changeset package target validation failed:', file=sys.stderr)
    for error in errors:
        print(f'- {error}', file=sys.stderr)
    sys.exit(1)

print(f'Validated {len(paths)} changeset file(s): none target the `main` group.')
PY
