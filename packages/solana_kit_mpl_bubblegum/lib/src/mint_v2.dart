/// Composite helper for minting a V2 compressed NFT.
library;

import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/programs/mpl_bubblegum.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/enums.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';

/// Input for minting a V2 compressed NFT.
class MintV2Input {
  /// Creates a [MintV2Input].
  const MintV2Input({
    required this.merkleTree,
    required this.leafOwner,
    required this.leafDelegate,
    required this.payer,
    required this.treeDelegate,
    required this.collectionAuthority,
    required this.name,
    required this.uri,
    this.symbol = '',
    this.sellerFeeBasisPoints = 0,
    this.creators = const [],
    this.collection,
    this.assetData,
    this.assetDataSchema,
  });

  /// The address of the Merkle tree to mint into.
  final Address merkleTree;

  /// The owner of the new compressed NFT.
  final Address leafOwner;

  /// The delegate of the new compressed NFT (defaults to leafOwner).
  final Address leafDelegate;

  /// The payer for the transaction.
  final Address payer;

  /// The tree delegate (must be the tree authority or have been delegated).
  final Address treeDelegate;

  /// The collection authority (must sign to verify collection).
  final Address collectionAuthority;

  /// The name of the asset.
  final String name;

  /// URI pointing to JSON representing the asset.
  final String uri;

  /// The symbol for the asset.
  final String symbol;

  /// Royalty basis points (0-10000).
  final int sellerFeeBasisPoints;

  /// Creators.
  final List<Creator> creators;

  /// The collection address this NFT belongs to.
  final Address? collection;

  /// Optional asset data bytes.
  final List<int>? assetData;

  /// Optional asset data schema.
  final AssetDataSchema? assetDataSchema;
}

/// Configuration for [getMintV2InstructionPlan].
class MintV2Config {
  /// Creates a [MintV2Config].
  const MintV2Config({
    this.logWrapper,
    this.compressionProgram,
    this.systemProgram,
    this.mplCoreProgram,
    this.mplCoreCpiSigner,
    this.coreCollection,
  });

  /// Log wrapper program address (noop program).
  final Address? logWrapper;

  /// SPL Account Compression program address.
  final Address? compressionProgram;

  /// System program address.
  final Address? systemProgram;

  /// MPL Core program address.
  final Address? mplCoreProgram;

  /// MPL Core CPI signer PDA.
  final Address? mplCoreCpiSigner;

  /// Core collection asset address.
  final Address? coreCollection;
}

/// Creates an instruction plan that mints a new V2 compressed NFT.
///
/// Mints a V2 compressed NFT into the specified Merkle tree.
///
/// ```dart
/// final plan = getMintV2InstructionPlan(
///   MintV2Input(
///     merkleTree: treeAddress,
///     leafOwner: ownerAddress,
///     leafDelegate: ownerAddress,
///     payer: payerAddress,
///     treeDelegate: treeDelegateAddress,
///     collectionAuthority: collectionAuthorityAddress,
///     name: 'My NFT',
///     uri: 'https://example.com/metadata.json',
///     creators: [
///       Creator(address: creatorAddress, verified: false, share: 100),
///     ],
///   ),
/// );
/// ```
InstructionPlan getMintV2InstructionPlan(
  MintV2Input input, [
  MintV2Config config = const MintV2Config(),
]) {
  final logWrapper =
      config.logWrapper ?? const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK');
  final compressionProgram =
      config.compressionProgram ?? const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi');
  final systemProgram =
      config.systemProgram ?? const Address('11111111111111111111111111111112');
  final mplCoreProgram =
      config.mplCoreProgram ?? const Address('CoREENxT6tW1HoJmSkLZP4xizQrmYMahYpv2UKJF2mLQ');
  final mplCoreCpiSigner =
      config.mplCoreCpiSigner ?? const Address('CpiSigner111111111111111111111111111111111111');
  final coreCollection =
      config.coreCollection ?? input.merkleTree; // Default to tree if not provided

  // Encode the MetadataArgsV2 manually since the generated encoder has a bug
  final metadataBytes = encodeMetadataArgsV2(
    name: input.name,
    symbol: input.symbol,
    uri: input.uri,
    sellerFeeBasisPoints: input.sellerFeeBasisPoints,
    primarySaleHappened: false,
    isMutable: true,
    editionNonce: null,
    tokenStandard: TokenStandard.nonFungible.value,
    collection: input.collection,
    uses: null,
    tokenProgramVersion: TokenProgramVersion.original.value,
    creators: input.creators,
  );

  // Build the instruction data manually:
  // discriminator (1 byte) + metadata args + optional asset data
  final assetData = input.assetData;
  final assetDataSchema = input.assetDataSchema;

  final dataSize = 1 + metadataBytes.length +
      (assetData != null ? 4 + assetData.length + 1 : 0);
  final data = Uint8List(dataSize);

  // Write discriminator (15 = MintV2)
  data[0] = 15;

  // Write metadata args bytes
  data.setRange(1, 1 + metadataBytes.length, metadataBytes);

  // Write optional asset data if present
  if (assetData != null) {
    var offset = 1 + metadataBytes.length;
    // Write asset data length as u32 LE
    data[offset] = assetData.length & 0xFF;
    data[offset + 1] = (assetData.length >> 8) & 0xFF;
    data[offset + 2] = (assetData.length >> 16) & 0xFF;
    data[offset + 3] = (assetData.length >> 24) & 0xFF;
    offset += 4;
    // Write asset data bytes
    data.setRange(offset, offset + assetData.length, assetData);
    offset += assetData.length;
    // Write asset data schema
    data[offset] = assetDataSchema?.value ?? 0;
  }

  // Build the instruction manually
  return sequentialInstructionPlan([
    Instruction(
      programAddress: mplBubblegumProgramAddressObject,
      accounts: [
        AccountMeta(address: input.merkleTree, role: AccountRole.writable),
        AccountMeta(address: input.payer, role: AccountRole.writableSigner),
        AccountMeta(address: input.treeDelegate, role: AccountRole.readonlySigner),
        AccountMeta(address: input.collectionAuthority, role: AccountRole.readonlySigner),
        AccountMeta(address: input.leafOwner, role: AccountRole.readonly),
        AccountMeta(address: input.leafDelegate, role: AccountRole.readonly),
        AccountMeta(address: input.merkleTree, role: AccountRole.writable),
        AccountMeta(address: coreCollection, role: AccountRole.writable),
        AccountMeta(address: mplCoreCpiSigner, role: AccountRole.readonly),
        AccountMeta(address: logWrapper, role: AccountRole.readonly),
        AccountMeta(address: compressionProgram, role: AccountRole.readonly),
        AccountMeta(address: mplCoreProgram, role: AccountRole.readonly),
        AccountMeta(address: systemProgram, role: AccountRole.readonly),
      ],
      data: data,
    ),
  ]);
}
