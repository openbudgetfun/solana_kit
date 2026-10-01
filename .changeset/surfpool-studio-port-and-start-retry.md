---
"solana_kit_surfpool": patch
---

# Give every Surfnet a dedicated Studio port and retry port-race startups

Surfpool always binds its Studio/scenario server — even under `--no-studio` — and defaults every instance to the same fixed port, so concurrent Surfnets (one per parallel integration test file) collided on it. `SurfnetConfig` gains an optional `studioPort`, and each started instance now passes a distinct `--studio-port`, auto-allocated away from the RPC and WebSocket ports when omitted.

Port probing also released each port before the CLI bound it, so under parallel startup another process could claim the probed port in between and make `surfpool start` exit with `... port N is already in use` — the failure mode Surfpool 1.6.0 now reports instead of panicking. Starts with at least one auto-allocated port are retried with freshly probed ports (up to three attempts) when the CLI exits on a bind failure; a config that pins every port still fails immediately, since that conflict is deterministic.
