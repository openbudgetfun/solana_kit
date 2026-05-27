/// Composite helper for minting a compressed NFT.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/instructions/mint_v1.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/programs/mpl_bubblegum.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';

/// Input for minting a compressed NFT.
class MintV1Input {
  const MintV1Input({
    required this.merkleTree,
    required this.leafOwner,
    required this.leafDelegate,
    required this.payer,
    required this.treeDelegate,
    required this.name,
    required this.uri,
    this.symbol = '',
    this.sellerFeeBasisPoints = 0,
    this.creators = const [],
    this.collection,
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

  /// The collection this NFT belongs to.
  final Address? collection;
}

/// Configuration for [getMintV1InstructionPlan].
class MintV1Config {
  const MintV1Config({
    this.logWrapper,
    this.compressionProgram,
    this.systemProgram,
  });

  /// Log wrapper program address (noop program).
  final Address? logWrapper;

  /// SPL Account Compression program address.
  final Address? compressionProgram;

  /// System program address.
  final Address? systemProgram;
}

/// Creates an instruction plan that mints a new compressed NFT.
///
/// Mints a V1 compressed NFT into the specified Merkle tree.
///
/// ```dart
/// final plan = getMintV1InstructionPlan(
///   MintV1Input(
///     merkleTree: treeAddress,
///     leafOwner: ownerAddress,
///     leafDelegate: ownerAddress,
///     payer: payerAddress,
///     treeDelegate: treeDelegateAddress,
///     name: 'My NFT',
///     uri: 'https://example.com/metadata.json',
///     creators: [
///       Creator(address: creatorAddress, verified: false, share: 100),
///     ],
///   ),
/// );
/// ```
InstructionPlan getMintV1InstructionPlan(
  MintV1Input input, [
  MintV1Config config = const MintV1Config(),
]) {
  final logWrapper =
      config.logWrapper ?? const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK');
  final compressionProgram =
      config.compressionProgram ?? const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi');
  final systemProgram =
      config.systemProgram ?? const Address('11111111111111111111111111111112');

  final metadataArgs = MetadataArgs(
    name: input.name,
    symbol: input.symbol,
    uri: input.uri,
    sellerFeeBasisPoints: input.sellerFeeBasisPoints,
    creators: input.creators,
    collection: input.collection != null
        ? Collection(verified: false, key: input.collection!)
        : null,
  );

  return sequentialInstructionPlan([
    getMintV1Instruction(
      programAddress: mplBubblegumProgramAddressObject,
      treeAuthority: input.merkleTree,
      leafOwner: input.leafOwner,
      leafDelegate: input.leafDelegate,
      merkleTree: input.merkleTree,
      payer: input.payer,
      treeDelegate: input.treeDelegate,
      logWrapper: logWrapper,
      compressionProgram: compressionProgram,
      systemProgram: systemProgram,
      message: metadataArgs,
    ),
  ]);
}
