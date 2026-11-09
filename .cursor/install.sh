#!/usr/bin/env bash
# Idempotent cloud-agent bootstrap. Mirrors .github/actions/devenv:
# Nix, the devenv binary cache, devenv, the FVM Flutter SDK from .fvmrc,
# and workspace Dart packages (`install:all`).
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

if ! command -v curl >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get install -y --no-install-recommends ca-certificates curl git xz-utils
fi

if [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
	curl -fsSL https://nixos.org/nix/install | sh -s -- --daemon --yes
fi

sudo mkdir -p /etc/nix
if [ ! -f /etc/nix/nix.conf ]; then
	echo "build-users-group = nixbld" | sudo tee /etc/nix/nix.conf >/dev/null
fi

nix_conf_changed=0
add_nix_setting() {
	local key="$1"
	local line="$2"
	if sudo grep -Eq "^${key}[[:space:]]*=" /etc/nix/nix.conf; then
		return 0
	fi
	printf '%s\n' "$line" | sudo tee -a /etc/nix/nix.conf >/dev/null
	nix_conf_changed=1
}

add_nix_setting experimental-features "experimental-features = nix-command flakes"
add_nix_setting accept-flake-config "accept-flake-config = true"
add_nix_setting trusted-users "trusted-users = root ubuntu"

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ensure-nix-daemon.sh"

if [ "$nix_conf_changed" -eq 1 ]; then
	# The running daemon keeps its old config until it is restarted.
	sudo pkill -x nix-daemon >/dev/null 2>&1 || true
	sudo rm -f /nix/var/nix/daemon-socket/socket
fi

ensure_nix_daemon

if ! command -v cachix >/dev/null 2>&1; then
	nix profile add --accept-flake-config nixpkgs#cachix
fi

cachix use devenv

if ! command -v devenv >/dev/null 2>&1; then
	nix profile add nixpkgs#devenv
fi

# Login shells source nix.sh, but devenv shell is not one of them.
# shellcheck disable=SC1091
. /etc/profile.d/nix.sh

devenv shell -- bash -e <<'EOF'
set -euo pipefail
fvm install
fvm use --force
install:all
EOF
