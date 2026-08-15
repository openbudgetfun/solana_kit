# Committed Solana program artifacts

Compiled Solana program binaries (`.so`) used by the on-chain integration
tests in `packages/solana_kit_integration_tests`. They are committed to the
repository so the integration suite does not need to compile or fetch them
on every run.

## Programs

Artifact names follow `<package-name-minus-solana_kit>-<program-version>.so`
(e.g. `solana_kit_subscriptions` -> `subscriptions-v0.5.0.so`,
`solana_kit_mpl_bubblegum` -> `mpl_bubblegum-v0.12.0.so`). The version is the
program crate version at the pinned reference; when the pin moves to a version
that changes the program version, the artifact filename must be updated too.

| Artifact                            | Program                                                                                     | Pin / version                                                                                              |
| ----------------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `config-v3.0.0.so`                  | [solana-program/config](https://github.com/solana-program/config)                           | `solana-config-program-client@v1.1.0` (see `config/reference-repos.json`); Core BPF program, not a builtin |
| `subscriptions-v0.5.0.so`           | [solana-foundation/subscriptions](https://github.com/solana-foundation/subscriptions)       | `ts-client-v0.5.0` (see `config/reference-repos.json`)                                                     |
| `mpl_bubblegum-v0.12.0.so`          | [metaplex-foundation/mpl-bubblegum](https://github.com/metaplex-foundation/mpl-bubblegum)   | commit `68e4bc204099718f318d5fe258f60be09737416d` (see `config/reference-repos.json`)                      |
| `spl_account_compression-v0.3.3.so` | [solana-program/account-compression](https://github.com/solana-program/account-compression) | `ac-mainnet-tag` (see `config/reference-repos.json`)                                                       |
| `noop-v0.2.0.so`                    | [solana-program/account-compression](https://github.com/solana-program/account-compression) | `ac-mainnet-tag` (see `config/reference-repos.json`); built from the repo's `spl-noop` 0.2.0               |

## How these are built

All artifacts are **compiled from the pinned source with `cargo build-sbf`**
(agave 4.2.0 / platform-tools v1.54, provided by the devenv `agave` package) —
not downloaded from mainnet. Building from the pinned reference makes the
binaries reproducible and keeps them in sync with the generated Dart clients.

Artifact metadata (program dir, crate name, program ID, patch requirements)
lives in `config/programs/artifacts.json`; the reference pins live in
`config/reference-repos.json`.

## Regeneration

**When the pinned version of any of these programs changes (e.g. during an
upstream sync of a program client), the `.so` artifact must be regenerated** —
the committed binary is version-locked to the pin in
`config/reference-repos.json`.

### One-command rebuild

```bash
devenv shell -- bash -lc "node scripts/build_program_artifacts.mjs"
# or a single program:
devenv shell -- bash -lc "node scripts/build_program_artifacts.mjs --program=bubblegum"
```

The script clones/checks out each pinned repo under `.repos/`, applies the
ahash patch where needed, runs `cargo build-sbf`, copies the result to
`config/programs/<name>-v<version>.so`, and verifies the baked-in program ID.

### Manual steps (if the script needs adjusting)

1. Bump the reference pin in `config/reference-repos.json`.
2. Update the artifact version in `config/programs/artifacts.json` to the new
   program crate version (read from the program's `Cargo.toml`), and rename the
   artifact file to `<name>-v<version>.so`.
3. Ensure the repo is cloned at the pin:
   `git clone <url> .repos/<path>` then `git checkout <pin>`.
4. Build: `cd <program-dir> && cargo build-sbf` (inside the devenv shell).
5. Copy `target/deploy/<crate>.so` to `config/programs/<name>-v<version>.so`.
6. Verify the program ID is baked in (see `verifyProgramId` in the script) so
   PDA derivation works when deployed at the canonical address.
7. Update the integration tests that reference the artifact filename, then run
   the on-chain suite (`packages/solana_kit_integration_tests`).

### The ahash patch (solana-program 1.18.x programs)

Programs pinned to `solana-program 1.18.x` (bubblegum, account-compression,
noop) pull in `ahash 0.7.6`. The platform-tools rustc (1.89+) removed the
`stdsimd` feature gate, but agave's `cargo build-sbf` still injects
`--cfg feature="stdsimd"` for AES-NI hashing, so ahash fails with `E0635`.
The actual stdsimd code is ARM/AArch64-gated (inert on SBF), so the fix is to
remove the single `#![cfg_attr(feature = "stdsimd", feature(stdsimd))]` line
from a vendored copy of ahash 0.7.6 and wire it via `[patch.crates-io]` in the
Rust workspace root `Cargo.toml`. The build script does this automatically
(see `applyAhashPatch`). Programs on `solana-program 2.x` (subscriptions) build
cleanly without it.

## Canonical program IDs

The on-chain tests deploy these programs at their canonical addresses (the
programs bake their program ID into the binary, so PDA derivation only works
when deployed at the baked-in address):

- Subscriptions: `De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44`
- MPL Bubblegum: `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- SPL Account Compression: `cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK`
- Noop: `noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV`
- Config: `Config1111111111111111111111111111111111111`

The `solana_kit_address_constants` package ships these canonical IDs.
