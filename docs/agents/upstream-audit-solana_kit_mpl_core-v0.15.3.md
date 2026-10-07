# Upstream audit — metaplex-foundation/mpl-core release/core@0.15.2 → release/core@0.15.3

`release/core@0.15.3` was published on 2026-10-06. This note maps every change in that release to its Dart counterpart, so the compatibility claim can be audited.

Status: the workspace tracks `release/core@0.15.3` (`checkedCommit 8c5cee35199a`); `clone:repos:status` verifies the pin.

## Upstream changes

| Commit                                                                                  | Change                                                                                                                                                      |
| --------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `8c5cee3` Fix VerifiedCreators collection plugin blocking asset lifecycle events (#302) | On-chain program fix: the VerifiedCreators plugin's validation no longer runs for asset lifecycle events it must not gate, plus JS-client regression tests. |
| `05e3e60` / `8196523` Node.js version bumps (#303, #304)                                | CI-only: the workflows and `.github/.env` move from Node 20.x to 24.x.                                                                                      |

## Dart impact

**None.** The Shank IDL the Dart generation consumes (`idls/mpl_core.json`) is byte-identical between the two tags — the program fix changed Rust runtime validation logic, not any instruction, argument, account, or type layout. The codama generator run at the new pin therefore produces the same output as at the old pin.

The generator-vs-committed diff for `solana_kit_mpl_core` is unchanged by this pin move and remains the pre-existing renderer drift documented in earlier audits: line-wrapping and trailing-comma differences from a formatter-version change across every generated file, plus one doc-comment line the current renderer emits for `execute_v1` that the committed tree predates. Committing that drift is a separate renderer cleanup, not part of a pin advance.

## Reference pin

`config/reference-repos.json` advanced `mpl-core` from tag `release/core@0.15.2` (`checkedCommit e72d63e4118a`) to tag `release/core@0.15.3` (`checkedCommit 8c5cee35199a`).
