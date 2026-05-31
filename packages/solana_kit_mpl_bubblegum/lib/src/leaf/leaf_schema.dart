/// Leaf schema definitions for compressed NFT data.
///
/// These schemas represent the data stored at each leaf in the Merkle tree.
/// V1 and V2 schemas differ in their structure and hashing logic.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// V1 leaf schema for compressed NFTs.
///
/// Represents the data stored at a V1 leaf in the Merkle tree.
/// The leaf hash is computed from these fields.
class LeafSchemaV1 {
  /// Creates a V1 leaf schema.
  const LeafSchemaV1({
    required this.leafIndex,
    required this.merkleTree,
    required this.owner,
    required this.delegate,
    this.metadataHash,
  });

  /// The leaf index within the Merkle tree.
  final int leafIndex;

  /// The Merkle tree address.
  final Address merkleTree;

  /// The owner of the compressed NFT.
  final Address owner;

  /// The delegate (defaults to owner if not set).
  final Address delegate;

  /// The pre-computed metadata hash.
  final Uint8List? metadataHash;
}

/// V2 leaf schema for compressed NFTs.
///
/// Represents the data stored at a V2 leaf in the Merkle tree.
/// V2 adds collection, asset data, and flags fields compared to V1.
class LeafSchemaV2 {
  /// Creates a V2 leaf schema.
  const LeafSchemaV2({
    required this.leafIndex,
    required this.merkleTree,
    required this.owner,
    required this.delegate,
    this.collection,
    this.assetData,
    this.flags = 0,
    this.metadataHash,
  });

  /// The leaf index within the Merkle tree.
  final int leafIndex;

  /// The Merkle tree address.
  final Address merkleTree;

  /// The owner of the compressed NFT.
  final Address owner;

  /// The delegate (defaults to owner if not set).
  final Address delegate;

  /// The collection address, if any.
  final Address? collection;

  /// Custom asset data, if any.
  final Object? assetData;

  /// Flags indicating which optional fields are present.
  final int flags;

  /// The pre-computed metadata hash.
  final Uint8List? metadataHash;
}
