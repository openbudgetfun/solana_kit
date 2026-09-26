/// Metadata hashing for mpl-bubblegum compressed NFT leaves.
///
/// A leaf hash commits to a metadata hash rather than to the metadata itself:
/// V1 hashes the Borsh encoding of the metadata struct followed by its seller
/// fee, while V2 hashes the V2 encoding followed by its seller fee. Both are
/// Keccak-256 digests computed over the leaf-canonical metadata, so the raw
/// royalty companions from DAS must be resolved first (see
/// [toLeafMetadata] and [toLeafMetadataV2]).
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';
import 'package:solana_kit_mpl_bubblegum/src/hashing/hash.dart';
import 'package:solana_kit_mpl_bubblegum/src/leaf/leaf_metadata.dart';

/// Hashes a metadata value together with its creators, as Bubblegum stores it
/// on a V2 leaf.
///
/// The result is `keccak256(metadataHash || creatorsHash)`. Mirrors the
/// upstream `hashMetadataV2`. Accepts either metadata shape; the raw royalty
/// companions are applied before hashing.
Uint8List hashMetadataV2(Object metadata, [RoyaltyRawFields? raw]) {
  final leaf = toLeafMetadataV2(metadata, raw);
  return bubblegumHash([
    hashMetadataDataV2(leaf),
    hashMetadataCreators(leaf.creators),
  ]);
}

/// Hashes a V1 metadata value together with its creators.
///
/// The result is `keccak256(metadataHash || creatorsHash)`. Mirrors the
/// upstream `hashMetadata`.
Uint8List hashMetadata(MetadataArgs metadata, [RoyaltyRawFields? raw]) {
  final leaf = toLeafMetadata(metadata, raw);
  return bubblegumHash([
    hashMetadataData(leaf),
    hashMetadataCreators(leaf.creators),
  ]);
}

/// Hashes the V1 metadata body and its seller fee.
///
/// The result is `keccak256(keccak256(borsh(MetadataArgs)) || u16(sellerFee))`.
/// Mirrors the upstream `hashMetadataData`.
Uint8List hashMetadataData(MetadataArgs metadata, [RoyaltyRawFields? raw]) {
  final leaf = toLeafMetadata(metadata, raw);
  return bubblegumHash([
    bubblegumHash([encodeMetadataArgs(leaf)]),
    _u16Le(leaf.sellerFeeBasisPoints),
  ]);
}

/// Hashes the V2 metadata body and its seller fee.
///
/// The result is `keccak256(keccak256(borsh(MetadataArgsV2)) || u16(sellerFee))`.
/// Mirrors the upstream `hashMetadataDataV2`. Accepts either metadata shape.
Uint8List hashMetadataDataV2(Object metadata, [RoyaltyRawFields? raw]) {
  final leaf = toLeafMetadataV2(metadata, raw);
  return bubblegumHash([
    bubblegumHash([encodeMetadataArgsV2FromMetadata(leaf)]),
    _u16Le(leaf.sellerFeeBasisPoints),
  ]);
}

/// Hashes a creator array the way Bubblegum does when building a leaf.
///
/// Each creator is encoded as `address (32) || verified (u8) || share (u8)` and
/// the concatenation is hashed. Mirrors the upstream `hashMetadataCreators`.
Uint8List hashMetadataCreators(List<Creator> creators) {
  final buffer = BytesBuilder();
  for (final creator in creators) {
    buffer
      ..add(getAddressEncoder().encode(creator.address))
      ..addByte(creator.verified ? 1 : 0)
      ..addByte(creator.share);
  }
  return bubblegumHash([buffer.toBytes()]);
}

Uint8List _u16Le(int value) =>
    Uint8List.fromList([value & 0xFF, (value >> 8) & 0xFF]);

/// Borsh-encodes a [MetadataArgsV2] value.
///
/// The generated `encodeMetadataArgsV2` takes flattened named arguments, which
/// is awkward when the value is already a [MetadataArgsV2]; this adapter keeps
/// the call sites in this library readable. The byte layout is produced by the
/// generated encoder, not duplicated here.
Uint8List encodeMetadataArgsV2FromMetadata(MetadataArgsV2 metadata) {
  return encodeMetadataArgsV2(
    name: metadata.name,
    symbol: metadata.symbol,
    uri: metadata.uri,
    sellerFeeBasisPoints: metadata.sellerFeeBasisPoints,
    primarySaleHappened: metadata.primarySaleHappened,
    isMutable: metadata.isMutable,
    tokenStandard: metadata.tokenStandard.value,
    collection: metadata.collection,
    creators: metadata.creators,
  );
}

/// Encodes a Borsh string as a `u32` little-endian length prefix followed by
/// its UTF-8 bytes.
///
/// Exposed so callers assembling instruction data can match the encoding the
/// generated metadata encoders use.
Uint8List encodeBorshString(String value) {
  final bytes = utf8.encode(value);
  final buffer = BytesBuilder()
    ..add(_u32Le(bytes.length))
    ..add(bytes);
  return buffer.toBytes();
}

Uint8List _u32Le(int value) => Uint8List.fromList([
  value & 0xFF,
  (value >> 8) & 0xFF,
  (value >> 16) & 0xFF,
  (value >> 24) & 0xFF,
]);
