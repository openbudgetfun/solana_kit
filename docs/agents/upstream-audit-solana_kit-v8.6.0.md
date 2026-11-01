# Upstream audit — @solana/kit v8.5.0 → v8.6.0

`@solana/kit` v8.6.0 was released with five functional changes and one new error code. This note maps every change to its Dart counterpart, including the items deliberately not ported, so the compatibility claim can be audited.

Status: the workspace tracks `v8.6.0` (`checkedCommit 37301ae0f2e8`); `upstream:parity` passes against `@solana/kit@8.6.0`.

## Ported

| Upstream change                                                                                                                         | Dart counterpart                                                                                                                                                                                                                                                                                                               |
| --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `decompileTransactionConfig` exported so a v1 compiled message's config can be read without decompiling the whole message (#2134)       | `solana_kit_transaction_messages`: extracted from `decompile_message.dart` into a public `decompileTransactionConfig(int configMask, List<CompiledTransactionConfigValue>)`, exported from the package barrel. The private `_getV1Config` now delegates to it, preserving the port's empty-config-to-null decompile semantics. |
| `decodeTransactionFromRpcResponse` decodes the `transactionConfig` of a v1 `json` RPC response into `configMask`/`configValues` (#2132) | `solana_kit_transaction_introspection`: the v1 `'json'` branch reads `message.transactionConfig` and computes the mask/values via `getTransactionConfigMask`/`getTransactionConfigValues`, replacing the synthesized empty config.                                                                                             |
| Channel pool entry destruction is idempotent (#2121)                                                                                    | `solana_kit_rpc_subscriptions`: `destroyPoolEntry` returns early when the entry is already gone, so aborting the last subscriber of an errored/failed channel can no longer destroy an unrelated healthy channel.                                                                                                              |
| Sentinel check spans the encoded bytes and the appended sentinel (#2089-era boundary)                                                   | `solana_kit_codecs_core`: `addEncoderSentinel` builds `encodedBytes + sentinel` and rejects when the sentinel is found before the appended copy, so values ending with the sentinel's prefix (e.g. `6c` + sentinel `6c6c`) are rejected across the seam.                                                                       |

## Not ported yet

| Upstream change                               | Why deferred                                                                                                                                                                                                                                                                                                                                                                                              |
| --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `getSignersFromInstructionPlan` added (#2128) | Requires a `solana_kit_signers → solana_kit_instruction_plans` dependency edge. Upstream tolerates the resulting package cycle (instruction-plans already depends on signers), but this workspace's publish tooling rejects cyclic publish dependencies, so the edge cannot be added without restructuring. Deferred until the packages are layered differently or the publisher supports ordered cycles. |

## Reserved upstream code

| Code                                        | Why nothing throws it in Dart today                                                                                                    |
| ------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `walletFeatureVersionUnsupported` (8900007) | The wallet-account feature-negotiation surface is not implemented in the Dart port yet. Reserved with its upstream number and message. |

## Already equivalent

| Upstream change                                                                | Why there is nothing to port                                                                                                                                                                     |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `LEGACY_TRANSACTION_SIZE_LIMIT` / `V1_TRANSACTION_SIZE_LIMIT` exported (#2133) | The Dart `solana_kit_transactions` already exports `legacyTransactionSizeLimit` / `v1TransactionSizeLimit` from `transaction_size.dart` — the constants were public in this port from the start. |
| Docs-wide `api.mainnet-beta.solana.com` → `api.mainnet.solana.com` URL refresh | Documentation-only URL changes in TS doc comments; the Dart docs use the port's own examples.                                                                                                    |

## Reference pin

`config/reference-repos.json` advanced `kit` from tag `v8.5.0` (`checkedCommit f35eab56d68a`) to tag `v8.6.0` (`checkedCommit 37301ae0f2e8`). `versions.json` `@solana/kit` moved from `8.5.0` to `8.6.0`.
