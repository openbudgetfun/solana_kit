/// Abstract DAS API interface for compressed NFT operations.
///
/// This defines the minimum DAS API methods needed by mpl-bubblegum.
/// Implementations can be provided by any DAS API provider (Helius, QuickNode, etc.).
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/flags/leaf_schema_flags.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';
import 'package:solana_kit_mpl_bubblegum/src/leaf/leaf_metadata.dart';

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
    this.royalty,
    this.creatorsRaw,
    this.collection,
    this.mutable = true,
    this.editionNonce,
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

  /// Royalty information, including the leaf-only raw companions.
  final DasAssetRoyalty? royalty;

  /// Leaf creators from DAS `creators_raw`.
  ///
  /// DAS omits this unless the asset's royalties are inherited.
  final List<DasAssetCreator>? creatorsRaw;

  /// The collection this asset belongs to, derived from the `collection`
  /// grouping entry, with its verification flag.
  final Collection? collection;

  /// Whether the asset's metadata is mutable.
  final bool mutable;

  /// The asset's edition nonce, when DAS reports one.
  final int? editionNonce;
}

/// Ownership information for a DAS asset.
/// DAS API asset ownership data.
class DasAssetOwnership {
  /// Creates a [DasAssetOwnership].
  const DasAssetOwnership({
    required this.frozen,
    required this.nonTransferable,
    this.owner = '',
    this.delegate,
  });

  /// The current owner address reported by DAS.
  final String owner;

  /// The delegate address, or `null` if the owner has not delegated the asset.
  final String? delegate;

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
    this.collectionHash,
    this.assetDataHash,
    this.flags,
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

  /// The collection hash from DAS `compression.collection_hash`, when present.
  final String? collectionHash;

  /// The asset data hash from DAS `compression.asset_data_hash`, when present.
  final String? assetDataHash;

  /// The leaf schema V2 flags from DAS `compression.flags`, when present.
  final int? flags;
}

/// Content information for a DAS asset.
/// DAS API asset content data.
class DasAssetContent {
  /// Creates a [DasAssetContent].
  const DasAssetContent({this.metadata, this.jsonUri});

  /// Metadata information.
  final DasAssetMetadata? metadata;

  /// The off-chain metadata URI from DAS `content.json_uri`.
  ///
  /// This is the value Bubblegum hashes into the leaf as the metadata URI.
  final String? jsonUri;
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
    this.verified = false,
  });

  /// The grouping key (e.g., "collection").
  final String groupKey;

  /// The grouping value (e.g., the collection address).
  final String groupValue;

  /// Whether DAS reports the grouping as verified.
  final bool verified;
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

/// Royalty information for a DAS asset.
///
/// DAS reports the display view of an asset's royalties here. When an asset
/// inherits its seller fee from a Core collection, [basisPointsRaw] carries the
/// leaf value and [inherited] marks the inherit sentinel; otherwise the leaf
/// value is [basisPoints].
class DasAssetRoyalty {
  /// Creates a [DasAssetRoyalty].
  const DasAssetRoyalty({
    this.basisPoints,
    this.basisPointsRaw,
    this.primarySaleHappened,
    this.inherited = false,
  });

  /// The display royalty basis points from DAS `royalty.basis_points`.
  final int? basisPoints;

  /// The leaf royalty basis points from DAS `royalty.basis_points_raw`.
  ///
  /// DAS omits this unless the asset's royalties are inherited.
  final int? basisPointsRaw;

  /// Whether the asset's primary sale has happened.
  final bool? primarySaleHappened;

  /// Whether DAS reports the asset's seller fee as inherited.
  ///
  /// Set from `royalty.sfbp_inherited` or `royalty.inherited`, or when
  /// [basisPoints] equals the inherit sentinel.
  final bool inherited;
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
    required this.metadata,
    required this.currentMetadata,
    this.collectionHash,
    this.assetDataHash,
    this.flags,
    this.sellerFeeBasisPointsRaw,
    this.creatorsRaw,
    this.inherited = false,
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

  /// Display-aligned metadata mirroring DAS `royalty.basis_points` and
  /// `creators`. When the seller fee is inherited this holds the
  /// collection-resolved rate and payees.
  final MetadataArgs metadata;

  /// Canonical leaf metadata for V2 hash and write instructions.
  ///
  /// Uses the DAS raw royalty companions when the seller fee is inherited, so
  /// a hash computed from this value matches the leaf the tree stores.
  final MetadataArgsV2 currentMetadata;

  /// The collection hash from DAS `compression.collection_hash`, when present.
  final Uint8List? collectionHash;

  /// The asset data hash from DAS `compression.asset_data_hash`, when present.
  final Uint8List? assetDataHash;

  /// The validated leaf schema V2 flags from DAS `compression.flags`.
  ///
  /// `null` when DAS reports no flags or a value outside the known bit range.
  final int? flags;

  /// Leaf seller fee basis points from DAS `royalty.basis_points_raw`.
  ///
  /// Set only when DAS provides the raw value or the seller fee is inherited.
  /// `null` for ordinary assets.
  final int? sellerFeeBasisPointsRaw;

  /// Leaf creators from DAS `creators_raw`.
  ///
  /// Set only when DAS provides them or the seller fee is inherited. `null`
  /// for ordinary assets.
  final List<Creator>? creatorsRaw;

  /// Whether DAS reports the asset's seller fee as inherited.
  final bool inherited;
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

  final rootBytes = _base58ToBytes(proof.root);

  // Parse the proof nodes
  final proofNodes = proof.proof.map(_base58ToBytes).toList();

  final royalty = asset.royalty;
  final inherited =
      royalty?.inherited ?? royalty?.basisPoints == sellerFeeBasisPointsInherit;

  // Leaf `_raw` values are only present when DAS exposes them or when the
  // seller fee is inherited, in which case DAS omits them from its response.
  int? sellerFeeBasisPointsRaw;
  List<Creator>? creatorsRaw;
  if (royalty?.basisPointsRaw != null) {
    sellerFeeBasisPointsRaw = royalty!.basisPointsRaw;
  } else if (inherited) {
    sellerFeeBasisPointsRaw = sellerFeeBasisPointsInherit;
  }
  if (asset.creatorsRaw != null) {
    creatorsRaw = asset.creatorsRaw!.map(_toCreator).toList();
  } else if (inherited) {
    creatorsRaw = const [];
  }

  final collection = asset.collection;
  final metadata = MetadataArgs(
    name: asset.content?.metadata?.name ?? '',
    symbol: asset.content?.metadata?.symbol ?? '',
    uri: asset.content?.jsonUri ?? '',
    sellerFeeBasisPoints: royalty?.basisPoints ?? 0,
    primarySaleHappened: royalty?.primarySaleHappened ?? false,
    isMutable: asset.mutable,
    editionNonce: asset.editionNonce,
    collection: collection,
    creators: asset.creators.map(_toCreator).toList(),
  );

  return AssetWithProof(
    rpcAsset: asset,
    rpcAssetProof: proof,
    leafOwner: asset.ownership.owner,
    leafDelegate: asset.ownership.delegate ?? asset.ownership.owner,
    merkleTree: proof.treeId,
    root: rootBytes,
    dataHash: _base58ToBytes(asset.compression.dataHash),
    creatorHash: _base58ToBytes(asset.compression.creatorHash),
    nonce: BigInt.from(asset.compression.leafId),
    index: proof.nodeIndex - (1 << proof.proof.length),
    proof: proofNodes,
    metadata: metadata,
    currentMetadata: toLeafMetadataV2(
      metadata,
      RoyaltyRawFields(
        sellerFeeBasisPointsRaw: sellerFeeBasisPointsRaw,
        creatorsRaw: creatorsRaw,
      ),
    ),
    collectionHash: asset.compression.collectionHash == null
        ? null
        : _base58ToBytes(asset.compression.collectionHash!),
    assetDataHash: asset.compression.assetDataHash == null
        ? null
        : _base58ToBytes(asset.compression.assetDataHash!),
    flags: isValidLeafSchemaV2Flags(asset.compression.flags ?? -1)
        ? asset.compression.flags
        : null,
    sellerFeeBasisPointsRaw: sellerFeeBasisPointsRaw,
    creatorsRaw: creatorsRaw,
    inherited: inherited,
  );
}

/// Converts a DAS creator record into the on-chain [Creator] shape.
Creator _toCreator(DasAssetCreator creator) => Creator(
  address: Address(creator.address),
  verified: creator.verified,
  share: creator.share,
);

Uint8List _base58ToBytes(String encoded) {
  // Base58 decoding - simplified implementation
  const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  final result = <int>[];
  var num = BigInt.zero;
  for (var i = 0; i < encoded.length; i++) {
    final charIndex = alphabet.indexOf(encoded[i]);
    if (charIndex < 0) {
      throw FormatException('Invalid base58 character: ${encoded[i]}');
    }
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
