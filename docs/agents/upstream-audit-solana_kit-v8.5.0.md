# Upstream audit — @solana/kit v8.4.0 → v8.5.0

`@solana/kit` v8.5.0 was released on 2026-10-13. This note maps every change in that release to its Dart counterpart, including the items that are deliberately not ported, so the compatibility claim can be audited.

Status: the workspace tracks `v8.5.0` (`checkedCommit f35eab56d68a`); `upstream:parity` passes against `@solana/kit@8.5.0`.

## Ported

| Upstream change                                                                                                  | Dart counterpart                                                                                                                                                                                                                                                                                                      |
| ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `SysvarSlotHashes` / `SysvarRecentBlockhashes` gain the `u64` length prefix these accounts actually have (#2116) | `solana_kit_sysvars`: both entry arrays now use `PrefixedArraySize(getU64…)`. The previous `u32` prefix shifted every decoded entry by four bytes. Wire-format fix.                                                                                                                                                   |
| `getBase16Encoder` no longer drops a trailing lone hex digit; `'abc'` encodes as `[0xab, 0x0c]` (#2117)          | `solana_kit_codecs_strings`: the encoder pads the final digit into the low nibble instead of rejecting odd lengths; the previous strict-throw divergence is gone.                                                                                                                                                     |
| Zero-byte fixed-size item codecs are rejected with sentinel/remainder strategies (#2089), new error `…8078030`   | `solana_kit_codecs_data_structures`: construction-time rejection on both encoder and decoder with `codecsUnexpectedZeroFixedSizeItemForArrayLikeSizeStrategy` (context: `codecDescription`, `sizeStrategy`). The port's runtime zero-progress loop guards remain as defense in depth.                                 |
| Binary fixed-points allow `fractionalBits > totalBits` (#2102)                                                   | `solana_kit_fixed_points`: the shape restrictions in `BinaryFixedPoint` and the fixed-point codecs are removed; values that do not fit still fail the existing raw-range checks. Tests updated to the new behavior.                                                                                                   |
| Five new error codes (#2111, #2095, #2089)                                                                       | `solana_kit_errors`: `keysVerificationRequiresExtractablePublicKey` (3704007), `codecsUnexpectedZeroFixedSizeItemForArrayLikeSizeStrategy` (8078030), `walletInvalidMessageSignature` (8900004), `walletInvalidSignInOutput` (8900005), `walletInvalidNumberOfOutputs` (8900006) with upstream messages and contexts. |
| `verifySignature()` verifies strictly, rejecting small-order public keys and signature `R` components (#2095)    | Already equivalent: the Dart `verifySignature` predates the fix and rejects both the public key and the R component against the five small-order y coordinates (including non-canonical aliases), before invoking the verifier.                                                                                       |

## Reserved upstream codes with no throw site

| Code                                                                                                                       | Why nothing throws it in Dart today                                                                                                                                                          |
| -------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `keysVerificationRequiresExtractablePublicKey` (3704007)                                                                   | WebCrypto-specific: the Dart port verifies signatures with its own Ed25519 implementation whose public keys are always readable.                                                             |
| `walletInvalidMessageSignature` (8900004), `walletInvalidSignInOutput` (8900005), `walletInvalidNumberOfOutputs` (8900006) | The wallet-account message-signer surface (`@solana/wallet-account-signer` #2112) is not implemented in the Dart port yet. Reserving the numbers keeps error-code interop for when it lands. |

## Not applicable in Dart

| Upstream change                                                    | Why there is nothing to port                                                                                                                                                                                                                     |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `SolanaError` contexts type-checked without `ES2022.Error` (#2110) | TypeScript `lib` configuration concern; Dart error contexts are always typed. The behavior fixes it carried (the `unsupportedVersion` context on compile/decompile and the `SlotHistory` decoder contexts) are already present in the Dart port. |
| `@solana/rpc-graphql` schema additions, `plugin-interfaces` typing | No Dart counterpart for the GraphQL RPC surface; the plugin-interfaces change is TypeScript declaration plumbing.                                                                                                                                |

## Not ported yet

| Upstream change                                                                             | Why deferred                                                                                                                                                                                                                       |
| ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `getAddressEncoder`/`getAddressCodec` accept address-bearing objects (`HasAddress`) (#2115) | A type-level widening of the address encoder that ripples through every generated codec and the program-client core (the encoder input becomes `Address                                                                            |
| Wallet-account message signer verification (#2112)                                          | The Dart port does not implement `@solana/wallet-account-signer`. Porting it means standing up the package (signer + verification + polyfill notes) — deferred to its own PR. The three wallet error codes are reserved meanwhile. |

## Reference pin

`config/reference-repos.json` advanced `kit` from tag `v8.4.0` (`checkedCommit 0a296c6ba8cd`) to tag `v8.5.0` (`checkedCommit f35eab56d68a`). `versions.json` `@solana/kit` moved from `8.4.0` to `8.5.0`.
