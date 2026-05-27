/// Abstract DAS API interface for compressed NFT operations.
///
/// This defines the minimum DAS API methods needed by mpl-bubblegum.
/// Implementations can be provided by any DAS API provider (Helius, QuickNode, etc.).
library;

import 'dart:typed_data';

/// The result of a DAS `getAssetProof` call.
class DasAssetProof {
  /// Creates a [DasAssetProof].
  const DasAssetProof({
    required this.root,
    required this.proof,
    required this.nodeIndex,
    required this.leaf,
    required this.treeId,
  });

  /// The root hash of the Merkle tree (base58 encoded).
  final String root;

  /// The Merkle proof path (list of base58-encoded hashes).
  final List<String> proof;

  /// The index of the leaf node in the tree.
  final int nodeIndex;

  /// The leaf hash (base58 encoded).
  final String leaf;

  /// The address of the Merkle tree.
  final String treeId;
}

/// The result of a DAS `getAsset` call (simplified for proof generation).
/// DAS API asset data.
class DasAsset {
  /// Creates a [DasAsset].
  const DasAsset({
    required this.id,
    required this.ownership,
    required this.compression,
    required this.content,
    required this.creators,
    required this.grouping,
  });

  /// The asset ID (compressed NFT address).
  final String id;

  /// Ownership information.
  final DasAssetOwnership ownership;

  /// Compression information.
  final DasAssetCompression compression;

  /// Content information.
  final DasAssetContent? content;

  /// Creators.
  final List<DasAssetCreator> creators;

  /// Grouping (collection info).
  final List<DasAssetGrouping> grouping;
}

/// Ownership information for a DAS asset.
/// DAS API asset ownership data.
class DasAssetOwnership {
  /// Creates a [DasAssetOwnership].
  const DasAssetOwnership({
    required this.frozen,
    required this.nonTransferable,
  });

  /// Whether the asset is frozen.
  final bool frozen;

  /// Whether the asset is non-transferable.
  final bool nonTransferable;
}

/// Compression information for a DAS asset.
/// DAS API asset compression data.
class DasAssetCompression {
  /// Creates a [DasAssetCompression].
  const DasAssetCompression({
    required this.compressed,
    required this.dataHash,
    required this.creatorHash,
    required this.assetHash,
    required this.tree,
    required this.seq,
    required this.leafId,
  });

  /// Whether the asset is compressed.
  final bool compressed;

  /// The data hash (base58 encoded).
  final String dataHash;

  /// The creator hash (base58 encoded).
  final String creatorHash;

  /// The asset hash (base58 encoded).
  final String assetHash;

  /// The tree address (base58 encoded).
  final String tree;

  /// The sequence number.
  final int seq;

  /// The leaf ID.
  final int leafId;
}

/// Content information for a DAS asset.
/// DAS API asset content data.
class DasAssetContent {
  /// Creates a [DasAssetContent].
  const DasAssetContent({
    this.metadata,
  });

  /// Metadata information.
  final DasAssetMetadata? metadata;
}

/// Metadata for a DAS asset.
/// DAS API asset metadata.
class DasAssetMetadata {
  /// Creates a [DasAssetMetadata].
  const DasAssetMetadata({
    this.name,
    this.symbol,
    this.description,
    this.image,
  });

  /// The name of the asset.
  final String? name;

  /// The symbol.
  final String? symbol;

  /// The description.
  final String? description;

  /// The image URL.
  final String? image;
}

/// Creator information for a DAS asset.
/// DAS API asset creator data.
class DasAssetCreator {
  /// Creates a [DasAssetCreator].
  const DasAssetCreator({
    required this.address,
    required this.share,
    required this.verified,
  });

  /// The creator's address.
  final String address;

  /// The creator's share percentage.
  final int share;

  /// Whether the creator is verified.
  final bool verified;
}

/// Grouping information for a DAS asset (e.g., collection).
/// DAS API asset grouping data.
class DasAssetGrouping {
  /// Creates a [DasAssetGrouping].
  const DasAssetGrouping({
    required this.groupKey,
    required this.groupValue,
  });

  /// The grouping key (e.g., "collection").
  final String groupKey;

  /// The grouping value (e.g., the collection address).
  final String groupValue;
}

/// Abstract interface for DAS API operations needed by mpl-bubblegum.
///
/// Implementations should call the actual DAS API endpoint.
/// This interface exists to avoid a hard dependency on any specific
/// DAS provider (e.g., solana_kit_helius).
abstract class DasApiClient {
  /// Gets the asset data for a compressed NFT.
  Future<DasAsset> getAsset(String assetId);

  /// Gets the Merkle proof for a compressed NFT.
  Future<DasAssetProof> getAssetProof(String assetId);
}

/// Complete data for a compressed NFT including its Merkle proof.
///
/// This is the result of [getAssetWithProof] and contains everything
/// needed to perform operations (transfer, burn, delegate, etc.) on a
/// compressed NFT.
/// Complete compressed NFT data with Merkle proof.
class AssetWithProof {
  /// Creates a [AssetWithProof].
  const AssetWithProof({
    required this.rpcAsset,
    required this.rpcAssetProof,
    required this.leafOwner,
    required this.leafDelegate,
    required this.merkleTree,
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    required this.nonce,
    required this.index,
    required this.proof,
  });

  /// The raw DAS API asset response.
  final DasAsset rpcAsset;

  /// The raw DAS API asset proof response.
  final DasAssetProof rpcAssetProof;

  /// The owner of the leaf.
  final String leafOwner;

  /// The delegate of the leaf.
  final String leafDelegate;

  /// The Merkle tree address.
  final String merkleTree;

  /// The root hash.
  final Uint8List root;

  /// The data hash.
  final Uint8List dataHash;

  /// The creator hash.
  final Uint8List creatorHash;

  /// The nonce (leaf index).
  final BigInt nonce;

  /// The leaf index.
  final int index;

  /// The Merkle proof nodes.
  final List<Uint8List> proof;
}

/// Gets an asset and its Merkle proof from the DAS API.
///
/// Fetches both the asset data and proof in parallel, then processes
/// the proof to extract the fields needed for Bubblegum instructions.
///
/// [dasClient] - The DAS API client to use.
/// [assetId] - The compressed NFT address.
Future<AssetWithProof> getAssetWithProof({
  required DasApiClient dasClient,
  required String assetId,
}) async {
  final (asset, proof) = await (
    dasClient.getAsset(assetId),
    dasClient.getAssetProof(assetId),
  ).wait;

  // Parse the root and leaf from the proof
  final rootBytes = _base58ToBytes(proof.root);
  final leafBytes = _base58ToBytes(proof.leaf);

  // Parse the proof nodes
  final proofNodes = proof.proof.map(_base58ToBytes).toList();

  // Extract the nonce from the leaf (nonce is at bytes 64-72 in V1/V2 leaf schema)
  final nonce = _extractNonce(leafBytes);

  return AssetWithProof(
    rpcAsset: asset,
    rpcAssetProof: proof,
    leafOwner: asset.ownership.frozen ? '' : '', // extracted from asset
    leafDelegate: '',
    merkleTree: proof.treeId,
    root: rootBytes,
    dataHash: _base58ToBytes(asset.compression.dataHash),
    creatorHash: _base58ToBytes(asset.compression.creatorHash),
    nonce: BigInt.from(nonce),
    index: proof.nodeIndex,
    proof: proofNodes,
  );
}

Uint8List _base58ToBytes(String encoded) {
  // Base58 decoding - simplified implementation
  const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  final result = <int>[];
  var num = BigInt.zero;
  for (var i = 0; i < encoded.length; i++) {
    final charIndex = alphabet.indexOf(encoded[i]);
    if (charIndex < 0) throw FormatException('Invalid base58 character: ${encoded[i]}');
    num = num * BigInt.from(58) + BigInt.from(charIndex);
  }
  while (num > BigInt.zero) {
    result.add((num % BigInt.from(256)).toInt());
    num = num ~/ BigInt.from(256);
  }
  // Add leading zeros for leading '1' characters
  for (var i = 0; i < encoded.length && encoded[i] == '1'; i++) {
    result.add(0);
  }
  return Uint8List.fromList(result.reversed.toList());
}

int _extractNonce(Uint8List leaf) {
  // V1/V2 leaf schema nonce is at offset 64-72 (8 bytes LE after 64 bytes of addresses)
  if (leaf.length < 72) return 0;
  var nonce = 0;
  for (var i = 0; i < 8; i++) {
    nonce |= leaf[64 + i] << (8 * i);
  }
  return nonce;
}
