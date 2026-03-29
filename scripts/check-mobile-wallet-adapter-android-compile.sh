#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
PLUGIN_PATH="$ROOT_DIR/packages/solana_kit_mobile_wallet_adapter"

if [[ ! -d "$PLUGIN_PATH" ]]; then
  echo "Expected plugin path not found: $PLUGIN_PATH" >&2
  exit 1
fi

TMP_PARENT="$(mktemp -d)"
TMP_APP="$TMP_PARENT/mwa_compile_check"

cleanup() {
  rm -rf "$TMP_PARENT"
}
trap cleanup EXIT

echo "Creating temporary Flutter Android app for compile verification..."
flutter create \
  --platforms=android \
  --project-name mwa_compile_check \
  --org com.example \
  "$TMP_APP" \
  >/dev/null

pushd "$TMP_APP" >/dev/null

echo "Adding local plugin dependency and workspace overrides"
ROOT_DIR="$ROOT_DIR" PLUGIN_PATH="$PLUGIN_PATH" python3 <<'PY'
from pathlib import Path
import os

root_dir = Path(os.environ['ROOT_DIR'])
plugin_path = Path(os.environ['PLUGIN_PATH'])
pubspec_path = Path('pubspec.yaml')

entries = []
for package_pubspec in sorted((root_dir / 'packages').glob('*/pubspec.yaml')):
    name = None
    for line in package_pubspec.read_text().splitlines():
        if line.startswith('name:'):
            name = line.split(':', 1)[1].strip()
            break
    if name and name.startswith('solana_kit_'):
        entries.append((name, package_pubspec.parent))

lines = pubspec_path.read_text().splitlines()
out = []
inserted_dependency = False
for index, line in enumerate(lines):
    out.append(line)
    if line.strip() == 'dependencies:' and not inserted_dependency:
        out.append('  solana_kit_mobile_wallet_adapter:')
        out.append(f'    path: {plugin_path}')
        inserted_dependency = True

if not inserted_dependency:
    raise SystemExit('Could not find dependencies section in generated pubspec.yaml')

out.append('')
out.append('dependency_overrides:')
for name, package_dir in entries:
    out.append(f'  {name}:')
    out.append(f'    path: {package_dir}')

pubspec_path.write_text('\n'.join(out) + '\n')
PY

flutter pub get >/dev/null

cat > lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';

void main() {
  // Reference exported plugin API to ensure integration survives tree-shaking.
  final _ = MwaClientHostApi;
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('MWA compile check')))));
}
DART

echo "Building debug APK to validate Android native compilation..."
flutter build apk --debug --target-platform android-arm64

popd >/dev/null

echo "Android compile verification passed."
