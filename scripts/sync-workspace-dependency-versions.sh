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
  echo "No workspace packages found in $root_pubspec" >&2
  exit 1
fi

workspace_pubspecs=()
for package_path in "${workspace_paths[@]}"; do
  pubspec_path="$repo_root/$package_path/pubspec.yaml"
  if [[ ! -f "$pubspec_path" ]]; then
    echo "Workspace package pubspec not found: $pubspec_path" >&2
    exit 1
  fi
  workspace_pubspecs+=("$pubspec_path")
done

versions_file="$(mktemp)"
cleanup() {
  rm -f "$versions_file"
}
trap cleanup EXIT

for pubspec_path in "${workspace_pubspecs[@]}"; do
  if ! package_meta="$(
    awk '
      BEGIN { name = ""; version = "" }
      /^name:[[:space:]]*/ && name == "" { name = $2 }
      /^version:[[:space:]]*/ && version == "" { version = $2 }
      END {
        gsub(/^["'"'"']|["'"'"']$/, "", version)
        if (name == "") exit 1
        print name "\t" version
      }
    ' "$pubspec_path"
  )"; then
    echo "Failed to parse package name from: $pubspec_path" >&2
    exit 1
  fi

  package_name="${package_meta%%$'\t'*}"
  package_version="${package_meta#*$'\t'}"

  if [[ -n "$package_version" ]]; then
    if grep -q "^$package_name"$'\t' "$versions_file" 2>/dev/null; then
      echo "Duplicate workspace package name detected: $package_name" >&2
      exit 1
    fi
    printf '%s\t%s\n' "$package_name" "$package_version" >> "$versions_file"
  fi
done

total_mismatches=0
updated_files=0

for pubspec_path in "${workspace_pubspecs[@]}"; do
  output_file="$(mktemp)"
  report_file="$(mktemp)"

  awk -v mode="$mode" -v file="$pubspec_path" -v report="$report_file" '
    FNR == NR {
      split($0, parts, "\t")
      if (parts[1] != "" && parts[2] != "") versions[parts[1]] = parts[2]
      next
    }

    function starts_dependency_section(line, section_match) {
      if (match(line, /^([[:space:]]*)(dependencies|dev_dependencies|dependency_overrides):[[:space:]]*$/, section_match)) {
        in_dependency_section = 1
        dependency_section_indent = length(section_match[1])
        return 1
      }
      return 0
    }

    {
      line = $0

      if (starts_dependency_section(line, section_match)) {
        print line
        next
      }

      if (in_dependency_section) {
        if (line ~ /^[[:space:]]*$/) {
          print line
          next
        }

        match(line, /^([[:space:]]*)/, indent_match)
        current_indent = length(indent_match[1])

        if (current_indent <= dependency_section_indent) {
          in_dependency_section = 0
        } else {
          if (match(line, /^([[:space:]]*)([A-Za-z0-9_]+):[[:space:]]*(.*)$/, dependency_match)) {
            dependency_indent = dependency_match[1]
            dependency_name = dependency_match[2]
            dependency_value = dependency_match[3]

            sub(/[[:space:]]+$/, "", dependency_value)

            if ((dependency_name in versions) && dependency_value != "") {
              expected_version = "^" versions[dependency_name]

              dependency_value_core = dependency_value
              dependency_comment = ""
              comment_index = index(dependency_value, "#")
              if (comment_index > 0) {
                dependency_comment = substr(dependency_value, comment_index)
                dependency_value_core = substr(dependency_value, 1, comment_index - 1)
                sub(/[[:space:]]+$/, "", dependency_value_core)
              }

              if (dependency_value_core != expected_version) {
                printf("%s:%d %s expected %s but found %s\n", file, FNR, dependency_name, expected_version, dependency_value) >> report
                if (mode == "write") {
                  if (dependency_comment != "") {
                    line = dependency_indent dependency_name ": " expected_version " " dependency_comment
                  } else {
                    line = dependency_indent dependency_name ": " expected_version
                  }
                }
              }
            }
          }

          print line
          next
        }
      }

      if (starts_dependency_section(line, reenter_match)) {
        print line
        next
      }

      print line
    }
  ' "$versions_file" "$pubspec_path" > "$output_file"

  mismatch_count="$(wc -l < "$report_file" | tr -d '[:space:]')"
  if [[ "$mismatch_count" -gt 0 ]]; then
    total_mismatches=$((total_mismatches + mismatch_count))
    cat "$report_file"
    if [[ "$mode" == "write" ]]; then
      mv "$output_file" "$pubspec_path"
      updated_files=$((updated_files + 1))
    fi
  fi

  rm -f "$output_file" "$report_file"
done

if [[ "$mode" == "check" ]]; then
  if [[ "$total_mismatches" -gt 0 ]]; then
    echo "Found $total_mismatches workspace dependency version mismatches." >&2
    exit 1
  fi
  echo "All workspace dependency versions are aligned."
  exit 0
fi

if [[ "$total_mismatches" -eq 0 ]]; then
  echo "Workspace dependency versions are already aligned."
  exit 0
fi

echo "Updated $updated_files package pubspecs; fixed $total_mismatches workspace dependency constraints."
