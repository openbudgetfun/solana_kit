/// Composite helper for transferring a compressed NFT.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart' hide noopProgramAddress, splAccountCompressionProgramAddress, systemProgramAddress, tokenProgramAddress;
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_mpl_bubblegum/src/constants/program_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/instructions/transfer.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/programs/mpl_bubblegum.dart';

/// Input for transferring a compressed NFT.
/// Input for TransferInput.
class TransferInput {
  /// Creates a [TransferInput].
  const TransferInput({
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    required this.nonce,
    required this.index,
    required this.leafOwner,
    required this.leafDelegate,
    required this.merkleTree,
    required this.newLeafOwner,
  });

  /// The root hash of the Merkle tree.
  final List<int> root;

  /// The hash of the leaf data.
  final List<int> dataHash;

  /// The hash of the creator data.
  final List<int> creatorHash;

  /// The nonce (asset ID) of the compressed NFT.
  final BigInt nonce;

  /// The index of the leaf in the Merkle tree.
  final int index;

  /// The current owner of the compressed NFT.
  final Address leafOwner;

  /// The delegate of the compressed NFT (if delegated).
  final Address leafDelegate;

  /// The address of the Merkle tree.
  final Address merkleTree;

  /// The new owner of the compressed NFT.
  final Address newLeafOwner;
}

/// Configuration for [getTransferInstructionPlan].
/// Configuration for TransferConfig.
class TransferConfig {
  /// Creates a [TransferConfig].
  const TransferConfig({
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

/// Creates an instruction plan that transfers a compressed NFT.
///
/// Transfers ownership of the asset. The transaction must be signed by
/// either the leaf owner or leaf delegate.
///
/// ```dart
/// final plan = getTransferInstructionPlan(
///   TransferInput(
///     root: proof.root,
///     dataHash: proof.dataHash,
///     creatorHash: proof.creatorHash,
///     nonce: proof.nonce,
///     index: proof.index,
///     leafOwner: ownerAddress,
///     leafDelegate: ownerAddress,
///     merkleTree: treeAddress,
///     newLeafOwner: recipientAddress,
///   ),
/// );
/// ```
InstructionPlan getTransferInstructionPlan(
  TransferInput input, [
  TransferConfig config = const TransferConfig(),
]) {
  final logWrapper = config.logWrapper ?? noopProgramAddress;
  final compressionProgram =
      config.compressionProgram ?? splAccountCompressionProgramAddress;
  final systemProgram = config.systemProgram ?? systemProgramAddress;

  return sequentialInstructionPlan([
    getTransferInstruction(
      programAddress: mplBubblegumProgramAddressObject,
      treeAuthority: input.merkleTree,
      leafOwner: input.leafOwner,
      leafDelegate: input.leafDelegate,
      newLeafOwner: input.newLeafOwner,
      merkleTree: input.merkleTree,
      logWrapper: logWrapper,
      compressionProgram: compressionProgram,
      systemProgram: systemProgram,
      root: input.root,
      dataHash: input.dataHash,
      creatorHash: input.creatorHash,
      nonce: input.nonce,
      index: input.index,
    ),
  ]);
}
