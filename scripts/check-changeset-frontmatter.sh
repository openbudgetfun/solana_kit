#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

python3 - "$@" <<'PY'
from pathlib import Path
import re
import sys

allowed_values = {"patch", "minor", "major", "feat", "fix", "docs", "note"}

paths = [Path(arg) for arg in sys.argv[1:]]
if not paths:
    paths = sorted(Path(".changeset").glob("*.md"))

errors: list[str] = []

for path in paths:
    if not path.exists():
        errors.append(f"{path}: file does not exist")
        continue

    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        errors.append(f"{path}: missing opening frontmatter delimiter '---'")
        continue

    closing_index = None
    for index, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            closing_index = index
            break

    if closing_index is None:
        errors.append(f"{path}: missing closing frontmatter delimiter '---'")
        continue

    entries = [line.strip() for line in lines[1:closing_index] if line.strip()]
    if not entries:
        errors.append(f"{path}: frontmatter must contain at least one entry")
        continue

    for entry in entries:
        if ":" not in entry:
            errors.append(f"{path}: invalid frontmatter entry `{entry}`; expected `package: change_type`")
            continue

        key, value = [part.strip() for part in entry.split(":", 1)]
        if value not in allowed_values:
            errors.append(f"{path}: invalid change type `{value}` in `{entry}`; allowed: {', '.join(sorted(allowed_values))}")

if errors:
    print("Changeset frontmatter validation failed:", file=sys.stderr)
    for error in errors:
        print(f"- {error}", file=sys.stderr)
    sys.exit(1)

print(f"Validated {len(paths)} changeset file(s).")
PY
