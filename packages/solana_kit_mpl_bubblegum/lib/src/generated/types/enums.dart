// Auto-generated. Do not edit.
// ignore_for_file: type=lint



import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';

/// MetadataArgsV2 for V2 compressed NFTs.
///
/// This is the V2 metadata structure used by mintV2 and related instructions.
/// Unlike V1, V2 uses separate asset_data and collection fields.
@immutable
class MetadataArgsV2 {
  const MetadataArgsV2({
    required this.name,
    this.symbol = '',
    required this.uri,
    required this.sellerFeeBasisPoints,
    this.primarySaleHappened = false,
    this.isMutable = true,
    this.editionNonce,
    this.tokenStandard = TokenStandard.nonFungible,
    this.collection,
    this.uses,
    this.tokenProgramVersion = TokenProgramVersion.original,
    required this.creators,
  });

  final String name;
  final String symbol;
  final String uri;
  final int sellerFeeBasisPoints;
  final bool primarySaleHappened;
  final bool isMutable;
  final int? editionNonce;
  final TokenStandard tokenStandard;
  final Address? collection;
  final Uses? uses;
  final TokenProgramVersion tokenProgramVersion;
  final List<Creator> creators;
}

/// Update arguments for metadata updates.
@immutable
class UpdateArgs {
  const UpdateArgs({
    this.name,
    this.symbol,
    this.uri,
    this.sellerFeeBasisPoints,
    this.primarySaleHappened,
    this.isMutable,
    this.collection,
    this.uses,
    this.tokenStandard,
  });

  final String? name;
  final String? symbol;
  final String? uri;
  final int? sellerFeeBasisPoints;
  final bool? primarySaleHappened;
  final bool? isMutable;
  final Address? collection;
  final Uses? uses;
  final TokenStandard? tokenStandard;
}

/// Version enum (V1 or V2).
enum Version {
  v1(0),
  v2(1);

  const Version(this.value);
  final int value;
}

/// Leaf schema for compressed NFTs (V1 or V2).
///
/// This is used in Voucher accounts to identify which leaf schema
/// variant was used to create the leaf.
enum LeafSchemaVersion {
  v1(0),
  v2(1);

  const LeafSchemaVersion(this.value);
  final int value;
}

/// Decompressible state for a tree.
enum DecompressibleState {
  enabled(0),
  disabled(1);

  const DecompressibleState(this.value);
  final int value;
}

/// Asset data schema for V2 instructions.
enum AssetDataSchema {
  /// No special schema.
  none(0),

  /// MPL Core asset data schema.
  mplCore(1);

  const AssetDataSchema(this.value);
  final int value;
}

/// Bubblegum event types.
enum BubblegumEventType {
  /// Uninitialized event.
  uninitialized(0),

  /// Leaf schema event.
  leafSchema(1),

  /// Application data event.
  applicationData(2);

  const BubblegumEventType(this.value);
  final int value;
}

/// Instruction name enum.
enum InstructionName {
  unknown(0),
  mintV1(1),
  redeem(2),
  cancelRedeem(3),
  transfer(4),
  delegate(5),
  decompressV1(6),
  compress(7),
  burn(8),
  createTree(9),
  verifyCreator(10),
  unverifyCreator(11),
  setAndVerifyCollection(12),
  unverifyCollection(13),
  setDecompressibleState(14),
  setTreeDelegate(15),
  setCollectionV1(16),
  setCollectionV2(17),
  verifyCollection(18),
  updateMetadata(19),
  updateMetadataV2(20),
  burnV2(21),
  createTreeV2(22),
  collectV2(23),
  closeTreeV2(24),
  mintV2(25),
  transferV2(26),
  delegateV2(27),
  delegateAndFreezeV2(28),
  thawV2(29),
  thawAndRevokeV2(30),
  freezeV2(31),
  setNonTransferableV2(32),
  mintToCollectionV1(33),
  setAndVerifyCollectionV2(34),
  unverifyCollectionV2(35),
  verifyCreatorV2(36),
  unverifyCreatorV2(37),
  updateAssetDataV2(38);

  const InstructionName(this.value);
  final int value;
}