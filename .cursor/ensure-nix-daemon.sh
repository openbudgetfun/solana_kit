# Shared by install.sh and start.sh. Defines ensure_nix_daemon.
# The multi-user Nix daemon does not survive an environment snapshot, and this
# VM image may not run systemd, so start the daemon directly when it is down.

ensure_nix_daemon() {
	if [ -f /etc/profile.d/nix.sh ]; then
		# shellcheck disable=SC1091
		. /etc/profile.d/nix.sh
	fi

	if command -v nix >/dev/null 2>&1 && nix store info >/dev/null 2>&1; then
		return 0
	fi

	local daemon="/nix/var/nix/profiles/default/bin/nix-daemon"
	if [ ! -x "$daemon" ]; then
		echo "nix-daemon is not installed" >&2
		return 1
	fi

	sudo pkill -x nix-daemon >/dev/null 2>&1 || true
	sleep 0.2
	sudo rm -f /nix/var/nix/daemon-socket/socket
	# nohup so the daemon survives this script exiting.
	sudo nohup "$daemon" >/tmp/nix-daemon.log 2>&1 &

	local _
	for _ in $(seq 1 50); do
		if command -v nix >/dev/null 2>&1 && nix store info >/dev/null 2>&1; then
			return 0
		fi
		sleep 0.2
	done

	echo "nix-daemon did not become ready; see /tmp/nix-daemon.log" >&2
	return 1
}
