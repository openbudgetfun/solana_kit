#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
site_dir="$repo_root/docs/site"
port="${DOCS_SMOKE_PORT:-4173}"
base_path="${DOCS_BASE_PATH:-/}"

cd "$site_dir"
fvm flutter pub get
fvm dart run build_runner clean
PORT="${DOCS_BUILD_PORT:-9080}" fvm dart run jaspr_cli:jaspr build --dart-define="DOCS_BASE_PATH=${base_path}"

python3 -m http.server "$port" --directory build/jaspr >/tmp/solana-kit-docs-http.log 2>&1 &
server_pid=$!
trap 'kill "$server_pid" >/dev/null 2>&1 || true' EXIT

for _ in {1..20}; do
  if curl -fsS "http://127.0.0.1:${port}/" >/tmp/solana-kit-docs-home.html 2>/dev/null; then
    break
  fi
  sleep 0.5
done

curl -fsS "http://127.0.0.1:${port}/" >/tmp/solana-kit-docs-home.html
curl -fsS "http://127.0.0.1:${port}/getting-started/quick-start/" >/tmp/solana-kit-docs-quick-start.html

if ! rg -q "Solana Kit" /tmp/solana-kit-docs-home.html; then
  echo "Smoke check failed: homepage did not contain expected text." >&2
  exit 1
fi

if ! rg -q "Quick Start" /tmp/solana-kit-docs-quick-start.html; then
  echo "Smoke check failed: quick-start page did not contain expected text." >&2
  exit 1
fi

echo "Docs smoke test passed."
