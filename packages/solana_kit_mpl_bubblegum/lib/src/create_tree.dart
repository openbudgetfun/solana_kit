/// Composite helper for creating a compressed NFT tree.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/instructions/create_tree.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/programs/mpl_bubblegum.dart';

/// Input for creating a compressed NFT tree.
class CreateTreeInput {
  const CreateTreeInput({
    required this.merkleTree,
    required this.payer,
    required this.treeCreator,
    required this.maxDepth,
    required this.maxBufferSize,
    this.isPublic = false,
  });

  /// The address of the new Merkle tree account.
  final Address merkleTree;

  /// The payer for the transaction (must be a signer).
  final Address payer;

  /// The tree creator/owner (must be a signer).
  final Address treeCreator;

  /// The maximum depth of the Merkle tree (determines max number of leaves: 2^maxDepth).
  final int maxDepth;

  /// The maximum buffer size for concurrent updates.
  final int maxBufferSize;

  /// Whether the tree is public (anyone can mint) or private (only the tree delegate can mint).
  final bool isPublic;
}

/// Configuration for [getCreateTreeInstructionPlan].
class CreateTreeConfig {
  const CreateTreeConfig({
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

/// Creates an instruction plan that initializes a new compressed NFT tree.
///
/// This plan contains a single instruction:
/// 1. Bubblegum `CreateTree` — initializes the Merkle tree on-chain.
///
/// ```dart
/// final plan = getCreateTreeInstructionPlan(
///   CreateTreeInput(
///     merkleTree: merkleTreeAddress,
///     payer: payer,
///     treeCreator: payer,
///     maxDepth: 14,
///     maxBufferSize: 64,
///   ),
/// );
/// ```
InstructionPlan getCreateTreeInstructionPlan(
  CreateTreeInput input, [
  CreateTreeConfig config = const CreateTreeConfig(),
]) {
  final logWrapper =
      config.logWrapper ?? const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK');
  final compressionProgram =
      config.compressionProgram ?? const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi');
  final systemProgram =
      config.systemProgram ?? const Address('11111111111111111111111111111112');

  return sequentialInstructionPlan([
    getCreateTreeInstruction(
      programAddress: mplBubblegumProgramAddressObject,
      treeAuthority: input.merkleTree, // tree authority PDA is derived from tree
      merkleTree: input.merkleTree,
      payer: input.payer,
      treeCreator: input.treeCreator,
      logWrapper: logWrapper,
      compressionProgram: compressionProgram,
      systemProgram: systemProgram,
      maxDepth: input.maxDepth,
      maxBufferSize: input.maxBufferSize,
      isPublic: input.isPublic,
    ),
  ]);
}
