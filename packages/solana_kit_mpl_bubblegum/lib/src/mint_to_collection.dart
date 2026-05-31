/// Composite helper for minting a compressed NFT into a collection.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/instructions/mint_to_collection_v1.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/programs/mpl_bubblegum.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/metadata_args.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/types/types.dart';

/// Input for minting a compressed NFT into a collection.
class MintToCollectionV1Input {
  /// Creates a [MintToCollectionV1Input].
  const MintToCollectionV1Input({
    required this.merkleTree,
    required this.leafOwner,
    required this.leafDelegate,
    required this.payer,
    required this.treeDelegate,
    required this.collectionAuthority,
    required this.collectionAuthorityRecordPda,
    required this.collectionMint,
    required this.collectionMetadata,
    required this.editionAccount,
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

  /// The collection authority (must sign to verify collection).
  final Address collectionAuthority;

  /// The collection authority record PDA.
  final Address collectionAuthorityRecordPda;

  /// The collection mint address.
  final Address collectionMint;

  /// The collection metadata account.
  final Address collectionMetadata;

  /// The edition account for the collection.
  final Address editionAccount;

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

/// Configuration for [getMintToCollectionV1InstructionPlan].
class MintToCollectionV1Config {
  /// Creates a [MintToCollectionV1Config].
  const MintToCollectionV1Config({
    this.logWrapper,
    this.compressionProgram,
    this.tokenMetadataProgram,
    this.systemProgram,
    this.bubblegumSigner,
  });

  /// Log wrapper program address (noop program).
  final Address? logWrapper;

  /// SPL Account Compression program address.
  final Address? compressionProgram;

  /// Token Metadata program address.
  final Address? tokenMetadataProgram;

  /// System program address.
  final Address? systemProgram;

  /// Bubblegum signer PDA.
  final Address? bubblegumSigner;
}

/// Creates an instruction plan that mints a compressed NFT into a collection.
///
/// Mints a V1 compressed NFT into the specified Merkle tree with collection verification.
///
/// ```dart
/// final plan = getMintToCollectionV1InstructionPlan(
///   MintToCollectionV1Input(
///     merkleTree: treeAddress,
///     leafOwner: ownerAddress,
///     leafDelegate: ownerAddress,
///     payer: payerAddress,
///     treeDelegate: treeDelegateAddress,
///     collectionAuthority: collectionAuthorityAddress,
///     collectionAuthorityRecordPda: recordPda,
///     collectionMint: collectionMintAddress,
///     collectionMetadata: collectionMetadataAddress,
///     editionAccount: editionAccountAddress,
///     name: 'My NFT',
///     uri: 'https://example.com/metadata.json',
///     creators: [
///       Creator(address: creatorAddress, verified: false, share: 100),
///     ],
///   ),
/// );
/// ```
InstructionPlan getMintToCollectionV1InstructionPlan(
  MintToCollectionV1Input input, [
  MintToCollectionV1Config config = const MintToCollectionV1Config(),
]) {
  final logWrapper =
      config.logWrapper ??
      const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK');
  final compressionProgram =
      config.compressionProgram ??
      const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi');
  final tokenMetadataProgram =
      config.tokenMetadataProgram ??
      const Address('metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s');
  final systemProgram = config.systemProgram ?? systemProgramAddress;
  final bubblegumSigner =
      config.bubblegumSigner ??
      const Address('4ewWZC8gFBALAtdMk8KJgFnH3hBzALPjg4wLWtK6VF9k');

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
    getmintToCollectionV1Instruction(
      programAddress: mplBubblegumProgramAddressObject,
      treeAuthority: input.merkleTree,
      leafOwner: input.leafOwner,
      leafDelegate: input.leafDelegate,
      merkleTree: input.merkleTree,
      payer: input.payer,
      treeDelegate: input.treeDelegate,
      collectionAuthority: input.collectionAuthority,
      collectionAuthorityRecordPda: input.collectionAuthorityRecordPda,
      collectionMint: input.collectionMint,
      collectionMetadata: input.collectionMetadata,
      editionAccount: input.editionAccount,
      bubblegumSigner: bubblegumSigner,
      logWrapper: logWrapper,
      compressionProgram: compressionProgram,
      tokenMetadataProgram: tokenMetadataProgram,
      systemProgram: systemProgram,
      metadataArgs: metadataArgs,
    ),
  ]);
}
