// ignore_for_file: comment_references
/// Leaf-canonical metadata resolution for mpl-bubblegum compressed NFTs.
///
/// DAS reports two different views of an asset's royalties: the display view
/// (`royalty.basis_points`, `creators`) and, when an asset inherits its seller
/// fee from a Core collection, the raw leaf view (`royalty.basis_points_raw`,
/// `creators_raw`). The Merkle leaf hash is computed over the raw values, so
/// hashing or writing with the display values produces a proof the tree
/// rejects.
///
/// These helpers merge the raw companions into a metadata value to produce the
/// leaf-canonical form used for hashing and write instructions, stripping the
/// companions afterwards. The display-facing metadata is never mutated.
library;

import 'package:meta/meta.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';

/// The seller fee basis points value Bubblegum uses to mark a leaf whose
/// royalties are inherited from its collection rather than stored on the leaf.
///
/// Mirrors `SELLER_FEE_BASIS_POINTS_INHERIT` upstream. DAS reports this as
/// `royalty.basis_points` (and typically omits `basis_points_raw`) when a
/// Core collection's Royalties plugin supplies the rate.
const int sellerFeeBasisPointsInherit = 0xffff;

/// DAS-aligned leaf royalty companions.
///
/// Mirrors the `basis_points_raw` / `creators_raw` pair DAS exposes on an
/// asset whose royalties are inherited.
@immutable
class RoyaltyRawFields {
  /// Creates a [RoyaltyRawFields].
  const RoyaltyRawFields({this.sellerFeeBasisPointsRaw, this.creatorsRaw});

  /// Leaf seller fee basis points from DAS `royalty.basis_points_raw`.
  final int? sellerFeeBasisPointsRaw;

  /// Leaf creators from DAS `creators_raw`.
  final List<Creator>? creatorsRaw;
}

/// Whether [metadata] is V1 [MetadataArgs] shape, as produced by
/// [getAssetWithProof].
///
/// Mirrors `isV1MetadataArgs` upstream. The port distinguishes the two shapes
/// by type rather than by probing for `tokenProgramVersion`, so this predicate
/// exists for callers holding an `Object` from an untrusted source.
bool isV1MetadataArgs(Object metadata) => metadata is MetadataArgs;

/// Merges the optional leaf royalty companions into [metadata] and returns the
/// leaf-canonical value with the companions removed.
///
/// Resolution order is an explicit [raw] argument first, then companions
/// carried on [metadata] itself. When neither supplies a value the metadata is
/// returned unchanged apart from having the companions stripped.
///
/// Mirrors `resolveLeafRoyaltyFields` upstream, which is generic over the V1
/// and V2 metadata shapes. Dart has no structural generic constraints, so this
/// overload exposes the shared resolution and the typed entry points below
/// ([toLeafMetadata], [toLeafMetadataV2]) apply it to each shape.
({int sellerFeeBasisPoints, List<Creator> creators}) resolveLeafRoyaltyFields({
  required int sellerFeeBasisPoints,
  required List<Creator> creators,
  RoyaltyRawFields? metadataRaw,
  RoyaltyRawFields? raw,
}) {
  final resolvedSellerFeeBasisPoints =
      raw?.sellerFeeBasisPointsRaw ?? metadataRaw?.sellerFeeBasisPointsRaw;
  final resolvedCreators = raw?.creatorsRaw ?? metadataRaw?.creatorsRaw;

  if (resolvedSellerFeeBasisPoints == null && resolvedCreators == null) {
    return (
      sellerFeeBasisPoints: sellerFeeBasisPoints,
      creators: creators,
    );
  }

  return (
    sellerFeeBasisPoints: resolvedSellerFeeBasisPoints ?? sellerFeeBasisPoints,
    creators: resolvedCreators ?? creators,
  );
}

/// Builds leaf-canonical V1 metadata for write instructions and hashing.
///
/// Pass the [AssetWithProof] sibling raw fields as [raw] when present.
/// Mirrors `toLeafMetadata` upstream.
MetadataArgs toLeafMetadata(MetadataArgs metadata, [RoyaltyRawFields? raw]) {
  final resolved = resolveLeafRoyaltyFields(
    sellerFeeBasisPoints: metadata.sellerFeeBasisPoints,
    creators: metadata.creators,
    raw: raw,
  );
  return MetadataArgs(
    name: metadata.name,
    symbol: metadata.symbol,
    uri: metadata.uri,
    sellerFeeBasisPoints: resolved.sellerFeeBasisPoints,
    primarySaleHappened: metadata.primarySaleHappened,
    isMutable: metadata.isMutable,
    editionNonce: metadata.editionNonce,
    tokenStandard: metadata.tokenStandard,
    collection: metadata.collection,
    uses: metadata.uses,
    tokenProgramVersion: metadata.tokenProgramVersion,
    creators: resolved.creators,
  );
}

/// Builds leaf-canonical V2 metadata for write instructions and hashing.
///
/// Accepts either V1 [MetadataArgs] (converting its `Collection` to the V2
/// bare collection address) or native [MetadataArgsV2], plus the optional
/// [raw] siblings. Mirrors `toLeafMetadataV2` upstream.
MetadataArgsV2 toLeafMetadataV2(Object metadata, [RoyaltyRawFields? raw]) {
  if (metadata is MetadataArgs) {
    final leaf = toLeafMetadata(metadata, raw);
    return MetadataArgsV2(
      name: leaf.name,
      symbol: leaf.symbol,
      uri: leaf.uri,
      sellerFeeBasisPoints: leaf.sellerFeeBasisPoints,
      primarySaleHappened: leaf.primarySaleHappened,
      isMutable: leaf.isMutable,
      tokenStandard: leaf.tokenStandard,
      creators: leaf.creators,
      collection: leaf.collection?.key,
    );
  }
  if (metadata is MetadataArgsV2) {
    final resolved = resolveLeafRoyaltyFields(
      sellerFeeBasisPoints: metadata.sellerFeeBasisPoints,
      creators: metadata.creators,
      raw: raw,
    );
    return MetadataArgsV2(
      name: metadata.name,
      symbol: metadata.symbol,
      uri: metadata.uri,
      sellerFeeBasisPoints: resolved.sellerFeeBasisPoints,
      primarySaleHappened: metadata.primarySaleHappened,
      isMutable: metadata.isMutable,
      editionNonce: metadata.editionNonce,
      tokenStandard: metadata.tokenStandard,
      collection: metadata.collection,
      uses: metadata.uses,
      tokenProgramVersion: metadata.tokenProgramVersion,
      creators: resolved.creators,
    );
  }
  throw ArgumentError.value(
    metadata,
    'metadata',
    'Expected MetadataArgs or MetadataArgsV2',
  );
}

/// Leaf-canonical V1 metadata for write instructions and hashing, taken from an
/// [AssetWithProof]-like value with explicit raw siblings.
///
/// Mirrors `asCurrentMetadata` upstream.
MetadataArgs asCurrentMetadata(
  MetadataArgs metadata, [
  RoyaltyRawFields? raw,
]) => toLeafMetadata(metadata, raw);

/// Leaf-canonical V2 metadata for write instructions and hashing, taken from an
/// [AssetWithProof]-like value. Converts a V1 collection to the V2 bare
/// address option.
///
/// Mirrors `asCurrentMetadataV2` upstream.
MetadataArgsV2 asCurrentMetadataV2(
  Object metadata, [
  RoyaltyRawFields? raw,
]) => toLeafMetadataV2(metadata, raw);
