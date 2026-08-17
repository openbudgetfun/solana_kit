---
"solana_kit_surfpool": minor
---

# Isolate each Surfnet's runtime state in its own working directory

`Surfnet.startWithConfig` (and therefore `Surfnet.start`, `createSurfpoolClient`, and the integration-test environment) now runs the `surfpool start` process in a dedicated per-instance temporary working directory instead of the caller's current directory.

The `surfpool` CLI writes its runtime state — log files, validator keypairs, ledger, and other `.surfpool/` files — next to its working directory. When several Surfnets started concurrently (e.g. parallel test files under `test:all`, which runs all packages in one process with up to 12-way concurrency), those instances raced on the shared `.surfpool` directory: one instance's startup cleanup could delete another's freshly-created directory, making `surfpool start` exit with `Failed to create log file
.surfpool/logs/...: unable to create parent directory .surfpool/logs` before the readiness check.

Each instance now gets its own working directory, so concurrent Surfnets can never clobber each other's state. The temporary directory is removed when the instance is stopped (including when startup fails). Artifact discovery for `deployProgram` is unaffected: it still resolves `target/deploy/` from the caller-provided (or current) directory, independent of the process working directory.
