# Upstream audit — solana-program/token-2022 js@v0.20.0 → js@v0.20.1

`js@v0.20.1` is a patch release of the token-2022 JavaScript client. This note maps the changes to their Dart counterpart.

Status: the workspace tracks `js@v0.20.1` (`checkedCommit a2ef578666da`); `clone:repos:status` verifies the pin.

## Upstream changes

Ten commits: a Kit 8.6 dependency bump in the JS client, TS client/plugin updates, confidential-transfer proof-generation work (grouped ciphertext reuse), token-CLI keypair-path and tooling changes, and dependency bumps. The TypeScript client picks up a transfer-hook seed resolution improvement (#1565).

## Dart impact

**None.** The program's `idl.json` is byte-identical between the two pins, so the generated Dart accounts, instructions, and types are unchanged by construction. The generator was run at both pins and its output compared byte-for-byte — identical across all 127 generated files.

The Dart-relevant upstream change (#1565, transfer-hook seed resolution against a destination created in the same transaction) lives in the TypeScript client's instruction builders, which the Dart generated package does not share — the Dart port builds transfer-hook instructions from the program IDL, whose layout is unchanged.

## Reference pin

`config/reference-repos.json` advanced `token-2022` from tag `js@v0.20.0` (`checkedCommit bf0dd490ab8a`) to tag `js@v0.20.1` (`checkedCommit a2ef578666da`).
