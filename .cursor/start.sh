#!/usr/bin/env bash
# Bring the Nix daemon back after each cloud-agent boot. Dependency installs
# belong in install.sh; this script only starts the daemon.
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ensure-nix-daemon.sh"
ensure_nix_daemon
