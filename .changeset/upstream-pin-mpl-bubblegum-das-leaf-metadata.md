---
"solana_kit_mpl_bubblegum": minor
---

# Port the mpl-bubblegum DAS inherited-royalty leaf metadata

The reference pin moves from commit `07180c73` to the tag `release/bubblegum@2.0.0` (commit `79e1a195`), which carries upstream JS client v6.0.0 and the DAS `_raw` leaf-royalty work. Unlike the other program pins in this sync, this one carries real client behavior, so the corresponding port is included here.

## Why the inherited-royalty handling matters

Bubblegum hashes the _leaf_ value of the seller fee basis points into the Merkle leaf. When a compressed NFT inherits its royalties from a Core collection, DAS reports two different numbers: the display rate under `royalty.basis_points` and the leaf rate under `royalty.basis_points_raw` (frequently the `0xffff` inherit sentinel). Hashing or writing with the display value produces a proof the tree rejects. These helpers resolve the leaf-canonical metadata before hashing or building a write instruction, and never mutate the display value.

## New API

`solana_kit_mpl_bubblegum` now exports the leaf-metadata resolution helpers and the metadata hashes they feed:

```dart
import 'package:solana_kit_mpl_bubblegum/solana_kit_mpl_bubblegum.dart';

// Resolve leaf-canonical metadata from an AssetWithProof value.
final leafMetadata = asCurrentMetadataV2(
  asset.metadata,
  RoyaltyRawFields(
    sellerFeeBasisPointsRaw: asset.sellerFeeBasisPointsRaw,
    creatorsRaw: asset.creatorsRaw,
  ),
);

// Hash it the way the tree does.
final dataHash = hashMetadataDataV2(leafMetadata);
final leafHash = hashMetadataV2(leafMetadata);
```

- `toLeafMetadata`, `toLeafMetadataV2`, `resolveLeafRoyaltyFields`, `asCurrentMetadata`, `asCurrentMetadataV2`, `isV1MetadataArgs`, `RoyaltyRawFields`, and `sellerFeeBasisPointsInherit`.
- `hashMetadata`, `hashMetadataV2`, `hashMetadataData`, `hashMetadataDataV2`, and `hashMetadataCreators`.
- `DasAsset.royalty`, `DasAsset.creatorsRaw`, `DasAsset.collection`, `DasAsset.mutable`, and `DasAsset.editionNonce`; `DasAssetRoyalty`; `DasAssetContent.jsonUri`; `DasAssetGrouping.verified`; and the `collectionHash`, `assetDataHash`, and `flags` compression fields. `HeliusDasClient` parses all of them, so the DAS royalty data is no longer discarded on the way in.
- `AssetWithProof` gains required `metadata` and `currentMetadata` fields plus optional `collectionHash`, `assetDataHash`, `flags`, `sellerFeeBasisPointsRaw`, `creatorsRaw`, and `inherited`. `getAssetWithProof` derives them, including the inherit-sentinel fallback that supplies `0xffff` and an empty creator list when DAS omits the raw values.

`AssetWithProof`'s two new required fields make this a `minor` rather than a `patch` for callers that construct the type directly.

## Fixed alongside

Two encoders emitted byte layouts that did not match the on-chain program, so any instruction built from them would have been rejected:

- `encodeMetadataArgsV2` wrote the **V1** field layout — 63 bytes including `editionNonce`, `uses`, and `tokenProgramVersion`. The on-chain `MetadataArgsV2` struct has nine fields and no such members; the correct encoding is 60 bytes. This affected `mintV2`, whose handwritten builder called the broken encoder.
- `UpdateArgs` declared `collection`, `uses`, and `tokenStandard` and omitted `creators`, while the on-chain struct is `name`, `symbol`, `uri`, `creators`, `sellerFeeBasisPoints`, `primarySaleHappened`, `isMutable`. This made `updateMetadataV2` instruction data malformed.

Both now match, verified byte-for-byte against `@metaplex-foundation/mpl-bubblegum` 6.0.0's own serializers, and the previously-swallowed `mintV2` workaround is gone.
