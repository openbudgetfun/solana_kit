# Upstream audit — 2026-09-26

## Scope

Reference-pin refresh for the program, SDK, and wallet reference repositories tracked in `config/reference-repos.json`. `@solana/kit` itself did **not** move: the npm `latest` dist-tag is still `8.3.0`, matching the `@solana/kit` key in `versions.json`, so `versions.json`, the `solana_kit` ↔ `@solana/kit` parity table, and the upstream compatibility claim are unchanged by this audit.

Ten of the twenty-two configured pins had moved:

| Repository                            | Was               | Now                                        | Dart package                      |
| ------------------------------------- | ----------------- | ------------------------------------------ | --------------------------------- |
| `solana-program/system`               | `js@v0.14.1`      | `js@v0.15.0`                               | `solana_kit_system`               |
| `solana-program/token`                | `js@v0.16.1`      | `js@v0.17.0`                               | `solana_kit_token`                |
| `solana-program/token-2022`           | `js@v0.18.0`      | `js@v0.19.0`                               | `solana_kit_token_2022`           |
| `solana-program/address-lookup-table` | `js@v0.14.1`      | `js@v0.15.0`                               | `solana_kit_address_lookup_table` |
| `solana-program/memo`                 | `js@v0.14.1`      | `js@v0.15.0`                               | `solana_kit_memo`                 |
| `solana-program/compute-budget`       | `js@v0.18.1`      | `js@v0.19.0`                               | `solana_kit_compute_budget`       |
| `solana-program/stake`                | `js@v0.9.1`       | `js@v0.10.0`                               | `solana_kit_stake`                |
| `solana-program/loader-v3`            | `js@v0.6.1`       | `js@v0.7.0`                                | `solana_kit_loader`               |
| `solana-program/loader-v4`            | commit `5bb854db` | commit `76f8ce27`                          | `solana_kit_loader`               |
| `metaplex-foundation/mpl-bubblegum`   | commit `07180c73` | tag `release/bubblegum@2.0.0` (`79e1a195`) | `solana_kit_mpl_bubblegum`        |

Every other pin was already current: `kit` (`v8.3.0`), `espresso-cash-public`, `helius-sdk`, `mobile-wallet-adapter`, `subscriptions`, `associated-token-account`, `config`, `account-compression`, `mpl-token-metadata`, `mpl-core`, `squads-v4`, and `solana-attestation-service`.

## The program client releases are renderer-only

The eight `solana-program/*` JS client releases are the same mechanical change: upstream bumped `@codama/renderers-js` (and in three cases bumped Rust dependencies) and regenerated `clients/js/src/generated/**`. The diff in every one of those repositories is confined to the generated TypeScript client, `Cargo.lock`/`Cargo.toml`, and `package.json`.

The Dart packages are generated from each repository's **`idl.json`**, not from the TypeScript client, and `idl.json` is byte-identical between the old and new tags for all eight. Upstream's renderer change is a TypeScript type-level refactor — generated inputs move from `TransactionSigner<TAccount>` / `Address<TAccount>` to the `InstructionSignerInput` / `InstructionAccountInput` family, and instruction builders gain a `getAccountMetaFactory` helper. It changes no wire format, no account layout, and no instruction data.

`stake` is the only program repository whose `idl.json` blob changed, and only in its version headers: the Codama format version moves `1.8.0` → `1.9.2` and the program version `4.4.0` → `5.0.0`. The remaining IDL content is identical, and the Dart renderer emits no program version, so nothing in the generated Dart changes.

This was verified empirically rather than argued: the generator was run against the **old** pins and against the **new** pins, and the two outputs are byte-identical across all thirteen generated packages (`diff -rq` clean). The pin moves are output-neutral for the Dart workspace.

## mpl-bubblegum: the DAS inherited-royalty work, ported

`mpl-bubblegum` is the one repository where the intervening commits carry real client-side behavior, not just regeneration. It is also the one pin that moved from a commit to a **tag**: `release/bubblegum@2.0.0` at commit `79e1a195`, which is the newest immutable upstream ref carrying the DAS work.

Upstream's JS client v6.0.0 reworks how `getAssetWithProof` handles DAS inherited seller-fee-by-proxy royalties. The port now covers that surface:

| Upstream symbol                                                                                                                  | Dart counterpart                                                                                                                                                                                            |
| -------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `leafMetadata.ts` — `resolveLeafRoyaltyFields`, `toLeafMetadata`, `toLeafMetadataV2`, `asCurrentMetadata`, `asCurrentMetadataV2` | `resolveLeafRoyaltyFields`, `toLeafMetadata`, `toLeafMetadataV2`, `asCurrentMetadata`, `asCurrentMetadataV2`, and `isV1MetadataArgs` in `leaf_metadata.dart`                                                |
| `getAssetWithProof` `AssetWithProof` shape                                                                                       | `AssetWithProof` now carries required `metadata` and `currentMetadata` plus `sellerFeeBasisPointsRaw`, `creatorsRaw`, and `inherited`, and `getAssetWithProof` derives them including the sentinel fallback |
| `SELLER_FEE_BASIS_POINTS_INHERIT` (`0xffff`) and `isInheritedSfbpRoyalty`                                                        | `sellerFeeBasisPointsInherit` and the `DasAssetRoyalty.inherited` flag, which `HeliusDasClient` sets from `sfbp_inherited` / `inherited` or from the sentinel value                                         |
| `hashMetadata`, `hashMetadataV2`, `hashMetadataData`, `hashMetadataDataV2`, `hashMetadataCreators`                               | The same names in `metadata_hash.dart`                                                                                                                                                                      |

The DAS royalty data is no longer discarded on the way in: `DasAsset` gained `royalty`, `creatorsRaw`, `collection`, `mutable`, and `editionNonce`, `DasAssetRoyalty` models the raw companions, `DasAssetContent` gained `jsonUri`, `DasAssetGrouping` gained `verified`, and the compression block carries `collectionHash`, `assetDataHash`, and `flags`.

The generated IDL-derived layer remains unaffected: `idls/bubblegum.json` is byte-identical at both pins and the program crate stays `0.12.0`.

### Why the tag, not a commit

`release/bubblegum@2.0.0` versions the Rust client (`clients/rust/Cargo.toml` is `mpl-bubblegum` `3.0.0`) and, decisively, it is the exact revision of the DAS commit `#173` (`git` reports the tag and `79e1a195` as _identical_). The four commits between it and `main` only touch the release workflows (`deploy-rust-client.yml`, `publish-js-client.yml`) and crate manifests, so no client-visible behavior separates the tag from the branch head.

Upstream tags its JS client releases separately (`js@v*`), and the highest such tag is `js@v5.0.2`; JS client v6.0.0 was released without a tag. `release/bubblegum@2.0.0` is therefore the closest thing upstream publishes to a versioned pin for this work, and it is immutable where a branch head is not.

## Fixed alongside: two encoders that did not match the program

Auditing the generated update path surfaced two byte-layout bugs that predate this sync. Both made their instructions invalid on chain, so they are fixed here rather than only recorded:

- `encodeMetadataArgsV2` wrote the **V1** field layout — 63 bytes including `editionNonce`, `uses`, and `tokenProgramVersion`. The on-chain `MetadataArgsV2` (`state/metaplex_adapter.rs`), the Anchor IDL, and upstream's own `getMetadataArgsV2Serializer` all agree on nine fields and a 60-byte encoding with `creators` **before** `collection`. The handwritten `mintV2` builder called this encoder, so `mintV2` instruction data was malformed.
- `UpdateArgs` declared `collection`, `uses`, and `tokenStandard` and omitted `creators`. The on-chain struct is `name`, `symbol`, `uri`, `creators`, `sellerFeeBasisPoints`, `primarySaleHappened`, `isMutable`, each an `Option`, so `updateMetadataV2` instruction data was malformed.

Both are now verified byte-for-byte against `@metaplex-foundation/mpl-bubblegum` 6.0.0's own serializers, and the test suite asserts those vectors. The `mintV2` workaround comment ("the generated encoder has a bug") is gone because the bug is fixed.

The generated instruction-data codecs in `lib/src/generated/instructions/` still collapse `defined`-type arguments (`metadataArgs`, `currentMetadata`, `updateArgs`) to `getU8Encoder()`. That is a separate renderer limitation: `mpl-bubblegum` is not one of the packages `scripts/generate_program_packages.mjs` manages, so its generated layer is hand-committed and the fix belongs with the renderer, not here. Those codecs are not on the path the handwritten builders use.

## Reference pins

The two moving-ref pins advanced to their current upstream commits and `checkedCommit` values were updated to the peeled tag commits (annotated tags) for every tag pin, so `clone:repos:status` verifies each repository at an exact revision. `loader-v4` remains pinned to a commit because upstream still publishes no tag for that program.
