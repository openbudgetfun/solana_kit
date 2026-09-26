# Upstream audit — 2026-09-26

## Scope

Reference-pin refresh for the program, SDK, and wallet reference repositories tracked in `config/reference-repos.json`. `@solana/kit` itself did **not** move: the npm `latest` dist-tag is still `8.3.0`, matching the `@solana/kit` key in `versions.json`, so `versions.json`, the `solana_kit` ↔ `@solana/kit` parity table, and the upstream compatibility claim are unchanged by this audit.

Ten of the twenty-two configured pins had moved:

| Repository                            | Was               | Now                                               | Dart package                      |
| ------------------------------------- | ----------------- | ------------------------------------------------- | --------------------------------- |
| `solana-program/system`               | `js@v0.14.1`      | `js@v0.15.0`                                      | `solana_kit_system`               |
| `solana-program/token`                | `js@v0.16.1`      | `js@v0.17.0`                                      | `solana_kit_token`                |
| `solana-program/token-2022`           | `js@v0.18.0`      | `js@v0.19.0`                                      | `solana_kit_token_2022`           |
| `solana-program/address-lookup-table` | `js@v0.14.1`      | `js@v0.15.0`                                      | `solana_kit_address_lookup_table` |
| `solana-program/memo`                 | `js@v0.14.1`      | `js@v0.15.0`                                      | `solana_kit_memo`                 |
| `solana-program/compute-budget`       | `js@v0.18.1`      | `js@v0.19.0`                                      | `solana_kit_compute_budget`       |
| `solana-program/stake`                | `js@v0.9.1`       | `js@v0.10.0`                                      | `solana_kit_stake`                |
| `solana-program/loader-v3`            | `js@v0.6.1`       | `js@v0.7.0`                                       | `solana_kit_loader`               |
| `solana-program/loader-v4`            | commit `5bb854db` | commit `76f8ce27d3bcb7492e5adb83c6eae8b5a6d2ee39` | `solana_kit_loader`               |
| `metaplex-foundation/mpl-bubblegum`   | commit `07180c73` | commit `ad7d32b477625190704eb204741667b5df15221d` | `solana_kit_mpl_bubblegum`        |

Every other pin was already current: `kit` (`v8.3.0`), `espresso-cash-public`, `helius-sdk`, `mobile-wallet-adapter`, `subscriptions`, `associated-token-account`, `config`, `account-compression`, `mpl-token-metadata`, `mpl-core`, `squads-v4`, and `solana-attestation-service`.

## The program client releases are renderer-only

The eight `solana-program/*` JS client releases are the same mechanical change: upstream bumped `@codama/renderers-js` (and in three cases bumped Rust dependencies) and regenerated `clients/js/src/generated/**`. The diff in every one of those repositories is confined to the generated TypeScript client, `Cargo.lock`/`Cargo.toml`, and `package.json`.

The Dart packages are generated from each repository's **`idl.json`**, not from the TypeScript client, and `idl.json` is byte-identical between the old and new tags for all eight. Upstream's renderer change is a TypeScript type-level refactor — generated inputs move from `TransactionSigner<TAccount>` / `Address<TAccount>` to the `InstructionSignerInput` / `InstructionAccountInput` family, and instruction builders gain a `getAccountMetaFactory` helper. It changes no wire format, no account layout, and no instruction data.

`stake` is the only program repository whose `idl.json` blob changed, and only in its version headers: the Codama format version moves `1.8.0` → `1.9.2` and the program version `4.4.0` → `5.0.0`. The remaining IDL content is identical, and the Dart renderer emits no program version, so nothing in the generated Dart changes.

This was verified empirically rather than argued: the generator was run against the **old** pins and against the **new** pins, and the two outputs are byte-identical across all thirteen generated packages (`diff -rq` clean). The pin moves are output-neutral for the Dart workspace.

## mpl-bubblegum: JS SDK changes, not ported yet

`mpl-bubblegum` is the one repository where the intervening commits carry real client-side behavior, not just regeneration. Five commits separate the old and new pins:

- `Align getAssetWithProof with DAS inherited SFBP _raw fields (#173)`
- `Fix release PR creation in JS publish workflow (#178)`
- `chore: release JS client v6.0.0 (#179)`
- `chore: Release mpl-bubblegum version 4.0.0 (#180)`
- `Fix Rust client release flow: create release PR instead of pushing to main (#181)`

Upstream's JS client v6.0.0 reworks how `getAssetWithProof` handles DAS inherited seller-fee-by-proxy royalties. The new surface is:

| Upstream symbol                                                                                                                  | What it does                                                                                                                                  | Port status |
| -------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| `leafMetadata.ts` — `resolveLeafRoyaltyFields`, `toLeafMetadata`, `toLeafMetadataV2`, `asCurrentMetadata`, `asCurrentMetadataV2` | Merges the DAS `_raw` royalty companions (`basis_points_raw`, `creators_raw`) into leaf-canonical metadata for write instructions and hashing | Not ported  |
| `getAssetWithProof` `AssetWithProof` shape                                                                                       | `currentMetadata` is now required, and the new `sellerFeeBasisPointsRaw`, `creatorsRaw`, and `inherited` fields are carried on the result     | Not ported  |
| `SELLER_FEE_BASIS_POINTS_INHERIT` (`0xffff`) and `isInheritedSfbpRoyalty`                                                        | The inherit sentinel and its detector, imported from `@metaplex-foundation/digital-asset-standard-api`                                        | Not ported  |

The generated IDL-derived layer is unaffected: `idls/bubblegum.json` is byte-identical at both pins and the program crate version stays `0.12.0`, so the generated instruction builders, account codecs, and error definitions do not change. What is missing is the handwritten DAS helper layer, which is where the current port is thinner than upstream:

- The port's `AssetWithProof` (`packages/solana_kit_mpl_bubblegum/lib/src/das_api.dart`) carries `rpcAsset`, `rpcAssetProof`, `leafOwner`, `leafDelegate`, `merkleTree`, `root`, `dataHash`, `creatorHash`, `nonce`, `index`, and `proof`. It has no `currentMetadata`, `sellerFeeBasisPointsRaw`, `creatorsRaw`, or `inherited`, and its `DasAsset` model has no `royalty` field at all, so the DAS response's royalty data is currently discarded on the way in.
- The port hashes a caller-supplied `metadataHash` in `hashLeafV1`/`hashLeafV2` rather than computing it from metadata. There is no `hashMetadataData`/`hashMetadataV2` equivalent, and no `getMetadataArgsCodec` in the generated layer, so there is nothing today that could consume `resolveLeafRoyaltyFields`.

Porting this properly means adding the DAS royalty model to `DasAsset`, implementing the leaf-metadata resolution helpers, and computing metadata hashes in Dart — a multi-part change to a handwritten package, not a pin refresh. **It is deliberately not ported in this sync.** The pin still advances because it changes no generated output and moves the workspace onto the newest IDL the renderer verifies against; the gap is recorded here so the compatibility claim stays auditable.

One separate correctness bug was noticed while reading the generated update path, outside the scope of this refresh: `packages/solana_kit_mpl_bubblegum/lib/src/generated/instructions/update_metadata_v2.dart` encodes and decodes `currentMetadata` and `updateArgs` as `getU8Encoder()` / `getU8Decoder()` while the TypeScript fields are typed `MetadataArgsV2` and `UpdateArgs` (the upstream IDL declares both as `defined` types). The generated layer does not yet render struct-typed instruction-account arguments, so these two fields serialized as one byte instead of their Borsh bodies. This predates the pin move and is unaffected by it (`idl.json` is identical at both pins); it is called out here because it will produce malformed `updateMetadataV2` instructions. Porting the leaf-metadata work above is the natural place to fix it.

## Reference pins

The two moving-ref pins advanced to their current upstream commits and `checkedCommit` values were updated to the peeled tag commits (annotated tags) for every tag pin, so `clone:repos:status` verifies each repository at an exact revision. `loader-v4` remains pinned to a commit because upstream still publishes no tag for that program.
