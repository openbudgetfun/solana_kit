#!/usr/bin/env bash
# Idempotent cloud-agent bootstrap.
# Installs multi-user Nix (flakes + nix-command), devenv from the devenv
# binary cache, and warms `devenv shell`. Dart dependencies are installed
# inside that shell. There is no non-devenv toolchain fallback.
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."

if ! command -v curl >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
	sudo apt-get update
	sudo apt-get install -y --no-install-recommends ca-certificates curl git xz-utils
fi

# Official multi-user installer, same family as CI's cachix/install-nix-action.
# This image does not run systemd, so start.sh launches nix-daemon directly.
if [ ! -x /nix/var/nix/profiles/default/bin/nix ]; then
	# A removed Nix install leaves these backups behind, and the installer
	# refuses to run again while they exist.
	sudo find /etc -name '*.backup-before-nix' -delete
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
# System-wide so the daemon uses the cache even for non-login shells.
add_nix_setting extra-substituters "extra-substituters = https://devenv.cachix.org"
add_nix_setting extra-trusted-public-keys "extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="

# shellcheck disable=SC1091
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/ensure-nix-daemon.sh"

if [ "$nix_conf_changed" -eq 1 ]; then
	# The running daemon keeps its old config until it is restarted.
	sudo pkill -x nix-daemon >/dev/null 2>&1 || true
	sudo rm -f /nix/var/nix/daemon-socket/socket
fi

ensure_nix_daemon

profile_has() {
	# nix colors the name when stdout is a terminal, which hides it from grep.
	nix profile list 2>/dev/null |
		sed 's/\x1b\[[0-9;]*m//g' |
		grep -Eq "(^|[[:space:]])${1}($|[[:space:]])"
}

if ! profile_has cachix; then
	nix profile install --accept-flake-config nixpkgs#cachix
fi

# Writes ~/.config/nix/nix.conf. The user is a trusted-user, so these
# substituters are accepted. /etc/nix/nix.conf carries the same cache.
cachix use devenv

if ! profile_has devenv; then
	nix profile install --accept-flake-config nixpkgs#devenv
fi

# /usr/local/bin is on the default PATH for login and non-login shells.
# Profile snippets are not: non-interactive bash skips ~/.bashrc.
link_on_path() {
	local name="$1"
	local target
	target="$(command -v "$name")"
	sudo ln -sfn "$target" "/usr/local/bin/$name"
}

link_on_path nix
link_on_path cachix
link_on_path devenv

# Build the devenv shell closure once so later `devenv shell` starts fast.
devenv shell -- true

devenv shell -- bash -e <<'EOF'
set -euo pipefail
fvm install
fvm use --force
install:all
EOF
