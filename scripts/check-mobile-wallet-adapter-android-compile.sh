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

echo "Adding local plugin dependency from $PLUGIN_PATH"
dart pub add solana_kit_mobile_wallet_adapter --path "$PLUGIN_PATH" >/dev/null

echo "Adding local overrides for workspace solana_kit_* dependencies"
{
  echo
  echo "dependency_overrides:"
  while IFS= read -r package_pubspec; do
    package_name="$(awk '/^name:[[:space:]]*/ { print $2; exit }' "$package_pubspec")"
    if [[ "$package_name" == solana_kit_* ]]; then
      package_dir="$(dirname "$package_pubspec")"
      echo "  $package_name:"
      echo "    path: $package_dir"
    fi
  done < <(find "$ROOT_DIR/packages" -mindepth 2 -maxdepth 2 -name pubspec.yaml | sort)
} >> pubspec.yaml

dartsdk_path="$(command -v dart || true)"
if [[ -z "$dartsdk_path" ]]; then
  echo "dart executable not found in PATH" >&2
  exit 1
fi

"$dartsdk_path" pub get >/dev/null

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
