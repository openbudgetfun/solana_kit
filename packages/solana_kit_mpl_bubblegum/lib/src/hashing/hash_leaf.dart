// ignore_for_file: comment_references
/// Leaf hashing utilities for mpl-bubblegum V1 and V2 compressed NFTs.
///
/// Provides [hashLeafV1] and [hashLeafV2] functions that compute the
/// Keccak-256 leaf hash used in Bubblegum's Merkle trees. These hashes
/// are essential for verifying proofs and updating on-chain tree state.
///
/// V1 leaves use `nftVersion = 1` and include the leaf asset ID, owner,
/// delegate, leaf index, and metadata hash.
///
/// V2 leaves add collection, asset data, and flags fields.
///
/// Since PDA derivation is async in solana_kit, the callers must
/// pre-compute the leaf asset ID PDA using [findLeafAssetIdPda]
/// and pass it to these functions.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_mpl_bubblegum/src/flags/leaf_schema_flags.dart';
import 'package:solana_kit_mpl_bubblegum/src/hashing/hash.dart';

/// Encodes an [Address] into its 32-byte representation.
///
/// Uses the same base58 decoder that [Address] uses internally,
/// but returns the raw byte array suitable for hashing.
Uint8List _addressToBytes(Address address) {
  return getAddressEncoder().encode(address);
}

/// Hashes a V1 leaf for a compressed NFT in a Bubblegum tree.
///
/// This computes the leaf hash that is stored in the Merkle tree for
/// V1 compressed NFTs. The hash is computed as:
///
/// ```text
/// keccak256([
///   nftVersion (u8, value = 1),
///   leafAssetId (32 bytes, pre-derived PDA),
///   owner (32 bytes),
///   delegate (32 bytes, defaults to owner),
///   leafIndex (u64 LE),
///   metadataHash (32 bytes),
/// ])
/// ```
///
/// Use [findLeafAssetIdPda] to pre-compute the [leafAssetId] parameter.
Uint8List hashLeafV1({
  required Uint8List leafAssetId,
  required Address owner,
  required int leafIndex,
  required Uint8List metadataHash,
  Address? delegate,
}) {
  final effectiveDelegate = delegate ?? owner;
  final nftVersion = Uint8List(1)..[0] = 1;
  final leafIndexBytes = _writeUInt64LE(leafIndex);

  return bubblegumHash([
    nftVersion,
    leafAssetId,
    _addressToBytes(owner),
    _addressToBytes(effectiveDelegate),
    leafIndexBytes,
    metadataHash,
  ]);
}

/// Hashes a V2 leaf for a compressed NFT in a Bubblegum tree.
///
/// This computes the leaf hash for V2 compressed NFTs, which include
/// additional fields for collection, asset data, and flags:
///
/// ```text
/// keccak256([
///   nftVersion (u8, value = 2),
///   leafAssetId (32 bytes, pre-derived PDA),
///   owner (32 bytes),
///   delegate (32 bytes, defaults to owner),
///   leafIndex (u64 LE),
///   metadataHashV2 (32 bytes),
///   collectionHash (32 bytes),
///   assetDataHash (32 bytes, or keccak256([]) if null),
///   flags (u8),
/// ])
/// ```
///
/// Use [findLeafAssetIdPda] to pre-compute the [leafAssetId] parameter.
Uint8List hashLeafV2({
  required Uint8List leafAssetId,
  required Address owner,
  required int leafIndex,
  required Uint8List metadataHashV2,
  required LeafSchemaV2Flags flags,
  Address? collection,
  Uint8List? assetData,
  Address? delegate,
}) {
  final effectiveDelegate = delegate ?? owner;
  final nftVersion = Uint8List(1)..[0] = 2;
  final leafIndexBytes = _writeUInt64LE(leafIndex);

  final collectionHash = hashCollection(
    collection ?? const Address('11111111111111111111111111111111'),
  );
  final assetDataHash = hashAssetData(assetData);

  return bubblegumHash([
    nftVersion,
    leafAssetId,
    _addressToBytes(owner),
    _addressToBytes(effectiveDelegate),
    leafIndexBytes,
    metadataHashV2,
    collectionHash,
    assetDataHash,
    Uint8List.fromList([flags.value]),
  ]);
}

/// Hashes a collection public key.
///
/// Simply computes `keccak256(collectionBytes)` where
/// `collectionBytes` is the 32-byte public key.
Uint8List hashCollection(Address collection) {
  return bubblegumHash([_addressToBytes(collection)]);
}

/// Hashes optional asset data.
///
/// If [assetData] is null, returns `keccak256([])` (the hash of nothing).
/// If [assetData] is a [Uint8List], hashes it directly.
Uint8List hashAssetData(Uint8List? assetData) {
  if (assetData == null || assetData.isEmpty) {
    return keccak256(Uint8List(0));
  }
  return keccak256(assetData);
}

/// Writes an int64 value in little-endian format.
///
/// This is a helper for encoding leaf indices as 8-byte LE values.
Uint8List _writeUInt64LE(int value) {
  final buffer = Uint8List(8);
  for (var i = 0; i < 8; i++) {
    // ignore: avoid_js_rounding
    buffer[i] = (value >> (8 * i)) & 0xFF;
  }
  return buffer;
}
