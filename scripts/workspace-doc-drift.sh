#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/workspace-doc-drift.sh [--check|--write]

  --check  Validate generated workspace summary/graph blocks in docs (default)
  --write  Regenerate workspace summary/graph blocks in docs
USAGE
}

mode="${1:---check}"
if [[ "$mode" != "--check" && "$mode" != "--write" ]]; then
  usage
  exit 2
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readme_file="$repo_root/readme.md"
publishing_guide_file="$repo_root/docs/publishing-guide.md"

for file in "$readme_file" "$publishing_guide_file"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required file: $file" >&2
    exit 2
  fi
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

packages_file="$tmp_dir/packages.txt"
internal_packages_file="$tmp_dir/internal-packages.txt"
graph_lines_file="$tmp_dir/graph-lines.txt"
pubspecs_file="$tmp_dir/pubspecs.txt"

find "$repo_root/packages" -mindepth 2 -maxdepth 2 -name pubspec.yaml | sort > "$pubspecs_file"

while IFS= read -r pubspec; do
  package_name="$(awk '/^name:[[:space:]]*/ { print $2; exit }' "$pubspec")"
  if [[ -z "$package_name" ]]; then
    echo "Failed to parse package name from $pubspec" >&2
    exit 2
  fi

  printf '%s\n' "$package_name" >> "$packages_file"

  if grep -Eq '^publish_to:[[:space:]]*none[[:space:]]*$' "$pubspec"; then
    printf '%s\n' "$package_name" >> "$internal_packages_file"
  fi
done < "$pubspecs_file"

sort -u -o "$packages_file" "$packages_file"

while IFS= read -r pubspec; do
  package_name="$(awk '/^name:[[:space:]]*/ { print $2; exit }' "$pubspec")"
  deps_file="$tmp_dir/${package_name}.deps"

  awk '
    /^dependencies:[[:space:]]*$/ { in_dependencies = 1; next }
    in_dependencies == 1 {
      if ($0 ~ /^[^[:space:]]/) {
        in_dependencies = 0
        next
      }
      if ($0 ~ /^[[:space:]][[:space:]][A-Za-z0-9_]+:/) {
        dependency = $1
        sub(":", "", dependency)
        print dependency
      }
    }
  ' "$pubspec" | sort -u > "$deps_file"

  filtered_deps_file="$tmp_dir/${package_name}.workspace-deps"
  grep -xFf "$packages_file" "$deps_file" | sort -u > "$filtered_deps_file" || true

  deps_line="$(awk 'NF { if (count++) printf ", "; printf "%s", $0 } END { if (count == 0) printf "(none)" }' "$filtered_deps_file")"
  printf '%s -> %s\n' "$package_name" "$deps_line" >> "$graph_lines_file"
done < "$pubspecs_file"

if [[ -s "$internal_packages_file" ]]; then
  sort -u -o "$internal_packages_file" "$internal_packages_file"
else
  : > "$internal_packages_file"
fi
sort -u -o "$graph_lines_file" "$graph_lines_file"

total_packages="$(wc -l < "$packages_file" | tr -d '[:space:]')"
internal_packages="$(wc -l < "$internal_packages_file" | tr -d '[:space:]')"
publishable_packages="$((total_packages - internal_packages))"

internal_packages_list="$(awk 'NF { if (count++) printf ", "; printf "`%s`", $0 } END { if (count == 0) printf "(none)" }' "$internal_packages_file")"

summary_content_file="$tmp_dir/summary.md"
cat > "$summary_content_file" <<EOF_SUMMARY

This monorepo contains **$total_packages packages** under \`packages/\`: **$publishable_packages publishable** and **$internal_packages internal** ($internal_packages_list).

EOF_SUMMARY

graph_content_file="$tmp_dir/graph.md"
{
  echo
  echo '```text'
  cat "$graph_lines_file"
  echo '```'
  echo
} > "$graph_content_file"

replace_block() {
  local input_file="$1"
  local output_file="$2"
  local start_marker="$3"
  local end_marker="$4"
  local content_file="$5"

  awk \
    -v start_marker="$start_marker" \
    -v end_marker="$end_marker" \
    -v content_file="$content_file" '
      BEGIN {
        inside = 0
        found_start = 0
        found_end = 0
      }
      $0 == start_marker {
        print
        while ((getline new_line < content_file) > 0) {
          print new_line
        }
        close(content_file)
        inside = 1
        found_start = 1
        next
      }
      $0 == end_marker && inside == 1 {
        inside = 0
        found_end = 1
        print
        next
      }
      inside == 0 {
        print
      }
      END {
        if (inside == 1 || found_start == 0 || found_end == 0) {
          exit 3
        }
      }
    ' "$input_file" > "$output_file"
}

apply_or_check_file() {
  local file="$1"
  local updated_file="$tmp_dir/$(basename "$file").updated"

  cp "$file" "$updated_file.base"

  replace_block \
    "$updated_file.base" \
    "$updated_file.step1" \
    '<!-- workspace-summary:start -->' \
    '<!-- workspace-summary:end -->' \
    "$summary_content_file"

  replace_block \
    "$updated_file.step1" \
    "$updated_file" \
    '<!-- workspace-dependency-graph:start -->' \
    '<!-- workspace-dependency-graph:end -->' \
    "$graph_content_file"

  if [[ "$mode" == "--write" ]]; then
    mv "$updated_file" "$file"
  else
    if ! diff -u "$file" "$updated_file" >/dev/null; then
      echo "Workspace documentation drift detected in $file" >&2
      diff -u "$file" "$updated_file" >&2 || true
      return 1
    fi
  fi
}

apply_or_check_file "$readme_file"
apply_or_check_file "$publishing_guide_file"

if [[ "$mode" == "--write" ]]; then
  echo "Updated workspace summary and dependency graph blocks."
else
  echo "Workspace documentation blocks are up to date."
fi
