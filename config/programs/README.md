# Committed Solana program artifacts

Compiled Solana program binaries (`.so`) used by the on-chain integration tests in `packages/solana_kit_integration_tests`. They are committed to the repository so the integration suite does not need to compile or fetch them on every run.

## Programs

Artifact names follow `<package-name-minus-solana_kit>-<program-version>.so` (e.g. `solana_kit_subscriptions` -> `subscriptions-v0.5.0.so`, `solana_kit_mpl_bubblegum` -> `mpl_bubblegum-v0.12.0.so`). The version is the program crate version at the pinned reference; when the pin moves to a version that changes the program version, the artifact filename must be updated too.

| Artifact                            | Program                                                                                             | Pin / version                                                                                              |
| ----------------------------------- | --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `config-v3.0.0.so`                  | [solana-program/config](https://github.com/solana-program/config)                                   | `solana-config-program-client@v1.1.0` (see `config/reference-repos.json`); Core BPF program, not a builtin |
| `subscriptions-v0.5.0.so`           | [solana-foundation/subscriptions](https://github.com/solana-foundation/subscriptions)               | `ts-client-v0.5.0` (see `config/reference-repos.json`)                                                     |
| `mpl_bubblegum-v0.12.0.so`          | [metaplex-foundation/mpl-bubblegum](https://github.com/metaplex-foundation/mpl-bubblegum)           | commit `68e4bc204099718f318d5fe258f60be09737416d` (see `config/reference-repos.json`)                      |
| `spl_account_compression-v0.3.3.so` | [solana-program/account-compression](https://github.com/solana-program/account-compression)         | `ac-mainnet-tag` (see `config/reference-repos.json`)                                                       |
| `noop-v0.2.0.so`                    | [solana-program/account-compression](https://github.com/solana-program/account-compression)         | `ac-mainnet-tag` (see `config/reference-repos.json`); built from the repo's `spl-noop` 0.2.0               |
| `mpl_core-v0.2.0.so`                | [metaplex-foundation/mpl-core](https://github.com/metaplex-foundation/mpl-core)                     | commit `2181404f90c7dd27ab95fcb2472483c4a347ae8c` (see `config/reference-repos.json`)                      |
| `mpl_token_metadata-v1.14.0.so`     | [metaplex-foundation/mpl-token-metadata](https://github.com/metaplex-foundation/mpl-token-metadata) | commit `349e061053c6fc5b6b815e03e896e4db57012893` (see `config/reference-repos.json`)                      |
| `squads_multisig-v2.1.0.so`         | [Squads-Protocol/v4](https://github.com/Squads-Protocol/v4)                                         | commit `af94153ff77a28b6effe46b9c94baaa93742b48c` (see `config/reference-repos.json`)                      |
| `anchor_compatibility-v0.1.0.so`    | Local Anchor compatibility fixture                                                                  | `anchor-lang = 0.31.1`; source in `config/programs/fixtures/anchor-compatibility`                          |
| `anchor_event_imposter-v0.1.0.so`   | Local Anchor event-provenance fixture                                                               | Emits identical event bytes from a foreign program ID                                                      |

## How these are built

All artifacts are **compiled from the pinned source with `cargo build-sbf`** (agave 4.2.0 / platform-tools v1.54, provided by the devenv `agave` package) — not downloaded from mainnet. Building from the pinned reference makes the binaries reproducible and keeps them in sync with the generated Dart clients.

Artifact metadata (program dir, crate name, program ID, patch requirements) lives in `config/programs/artifacts.json`; the reference pins live in `config/reference-repos.json`.

## Regeneration

**When the pinned version of any of these programs changes (e.g. during an upstream sync of a program client), the `.so` artifact must be regenerated** — the committed binary is version-locked to the pin in `config/reference-repos.json`.

### One-command rebuild

```bash
devenv shell -- bash -lc "node scripts/build_program_artifacts.mjs"
# or a single program:
devenv shell -- bash -lc "node scripts/build_program_artifacts.mjs --program=bubblegum"
```

The script clones/checks out each pinned repo under `.repos/`, applies the ahash patch where needed, runs `cargo build-sbf`, copies the result to `config/programs/<name>-v<version>.so`, and verifies the baked-in program ID.

### Manual steps (if the script needs adjusting)

1. Bump the reference pin in `config/reference-repos.json`.
2. Update the artifact version in `config/programs/artifacts.json` to the new program crate version (read from the program's `Cargo.toml`), and rename the artifact file to `<name>-v<version>.so`.
3. Ensure the repo is cloned at the pin: `git clone <url> .repos/<path>` then `git checkout <pin>`.
4. Build: `cd <program-dir> && cargo build-sbf` (inside the devenv shell).
5. Copy `target/deploy/<crate>.so` to `config/programs/<name>-v<version>.so`.
6. Verify the program ID is baked in (see `verifyProgramId` in the script) so PDA derivation works when deployed at the canonical address.
7. Update the integration tests that reference the artifact filename, then run the on-chain suite (`packages/solana_kit_integration_tests`).

### Legacy Rust compatibility patches

Older programs pull in `ahash` releases whose removed `stdsimd` feature gate fails under current platform-tools. The build script downloads the exact configured `ahash` releases into private temporary directories, removes only that gate, and wires each version through `[patch.crates-io]` for the duration of the build. Token Metadata also selects blake3's portable implementation on Apple Silicon and temporarily updates `wasm-bindgen` to the first release accepted by the current Rust compiler. The source manifest and lockfile are restored even when a build fails; `scripts/build_program_artifacts.test.mjs` verifies those cleanup and isolation guarantees.

### Anchor fixtures

The Anchor programs are deliberately small and source-controlled. `anchor-compatibility` covers account initialization and mutation, events, signer and `has_one` constraints, and custom errors. `anchor-event-imposter` emits the same event discriminator and payload from a different program so event provenance can be tested on-chain.

Rebuild and copy both fixtures with:

```bash
devenv shell -- bash -lc '
  cd config/programs/fixtures/anchor-compatibility
  anchor build
  cp target/deploy/anchor_compatibility.so ../../anchor_compatibility-v0.1.0.so
  cp target/deploy/anchor_event_imposter.so ../../anchor_event_imposter-v0.1.0.so
  cp target/idl/anchor_compatibility.json ../../anchor_compatibility-v0.1.0.json
  cp target/idl/anchor_event_imposter.json ../../anchor_event_imposter-v0.1.0.json
'
```

## Canonical program IDs

The on-chain tests deploy these programs at their canonical addresses (the programs bake their program ID into the binary, so PDA derivation only works when deployed at the baked-in address):

- Subscriptions: `De1egAFMkMWZSN5rYXRj9CAdheBamobVNubTsi9avR44`
- MPL Bubblegum: `BGUMAp9Gq7iTEuizy4pqaxsTyUCBK68MDfK752saRPUY`
- SPL Account Compression: `cmtDvXumGCrqC1Age74AVPhSRVXJMd8PJS91L8KbNCK`
- Noop: `noopb9bkMVfRPU8AsbpTUg8AQkHtKwMYZiFUjNRtMmV`
- Config: `Config1111111111111111111111111111111111111`
- MPL Core: `CoREENxT6tW1HoK8ypY1SxRMZTcVPm7R94rH4PZNhX7d`
- MPL Token Metadata: `metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s`
- Squads V4: `SQDS4ep65T869zMMBKyuUq6aD6EgTu8psMjkvj52pCf`
- Anchor compatibility: `Fg6PaFpoGXkYsidMpWTK6W2BeZ7FEfcYkg476zPFsLnS`
- Anchor event imposter: `8MyZkLi7NVstEPYwQoSS9VtKAcaRzGNLqxwQX4VtwW1e`

The `solana_kit_address_constants` package ships these canonical IDs.
