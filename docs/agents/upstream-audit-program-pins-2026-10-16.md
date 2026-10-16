# Upstream audit — solana-program js client wave (2026-10-16)

Eight `solana-program` repositories published coordinated minor releases of their JavaScript clients. This note maps every change to its Dart counterpart, so the compatibility claim can be audited. One branch carries all eight pins because the releases are one coordinated wave.

Status: all eight workspace pins track the new tags (`checkedCommit`s below); `clone:repos:status` verifies each.

## Per-repo audit

| Repo                 | Old → New pin               | IDL `idl.json`                          | Dart impact                                                                                    |
| -------------------- | --------------------------- | --------------------------------------- | ---------------------------------------------------------------------------------------------- |
| system               | `js@v0.15.0` → `js@v0.16.0` | BYTE-IDENTICAL                          | None — TS client regeneration only.                                                            |
| token                | `js@v0.17.0` → `js@v0.18.0` | BYTE-IDENTICAL                          | None — TS client regeneration plus batch/`createMint` TS helpers the Dart port does not share. |
| token-2022           | `js@v0.19.0` → `js@v0.20.0` | BYTE-IDENTICAL                          | None — TS/CLI/Rust client churn only.                                                          |
| address-lookup-table | `js@v0.15.0` → `js@v0.16.0` | BYTE-IDENTICAL                          | None.                                                                                          |
| memo                 | `js@v0.15.0` → `js@v0.16.0` | BYTE-IDENTICAL                          | None.                                                                                          |
| compute-budget       | `js@v0.19.0` → `js@v0.20.0` | BYTE-IDENTICAL                          | None.                                                                                          |
| stake                | `js@v0.10.0` → `js@v0.11.0` | version string only (`5.0.0` → `5.1.1`) | None — generating the Dart package at both pins produces identical output.                     |
| loader-v3            | `js@v0.7.0` → `js@v0.8.0`   | BYTE-IDENTICAL                          | None.                                                                                          |

The Dart generated packages are produced from each repo's `idl.json`; with byte-identical IDLs the codama generator output is unchanged by construction, and the one IDL delta (stake's program version string) is proven output-neutral by generating at both pins and comparing byte-for-byte.

## checkedCommits

`config/reference-repos.json` advanced all eight pins: system `e9cb05138ea8`, token `31646dce3df0`, token-2022 `e6b4af36a3db`, address-lookup-table `03b77b9e852c`, memo `4a487432a7a5`, compute-budget `e189b8ca25ec`, stake `ba25b6c883e0`, loader-v3 `b9c8ab343229`.
