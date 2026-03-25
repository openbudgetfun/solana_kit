#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

python3 - "$@" <<'PY'
from pathlib import Path
import sys

allowed_values = {"patch", "minor", "major"}

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
    if len(entries) != 1:
        if not entries:
            errors.append(
                f"{path}: frontmatter must contain exactly one entry: `default: patch|minor|major`"
            )
        else:
            joined_entries = ", ".join(f"`{entry}`" for entry in entries)
            errors.append(
                f"{path}: frontmatter must only contain one `default:` entry; found {joined_entries}"
            )
        continue

    entry = entries[0]
    if ":" not in entry:
        errors.append(
            f"{path}: invalid frontmatter entry `{entry}`; expected `default: patch|minor|major`"
        )
        continue

    key, value = [part.strip() for part in entry.split(":", 1)]
    if key != "default" or value not in allowed_values:
        errors.append(
            f"{path}: expected `default: patch|minor|major`, found `{entry}`"
        )

if errors:
    print("Changeset frontmatter validation failed:", file=sys.stderr)
    for error in errors:
        print(f"- {error}", file=sys.stderr)
    sys.exit(1)

print(f"Validated {len(paths)} changeset file(s): all use `default:` frontmatter.")
PY
