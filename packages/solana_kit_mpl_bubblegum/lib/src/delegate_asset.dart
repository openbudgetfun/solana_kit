/// Composite helper for delegating a compressed NFT.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/instructions/delegate.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/programs/mpl_bubblegum.dart';

/// Input for delegating a compressed NFT.
class DelegateInput {
  const DelegateInput({
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    required this.nonce,
    required this.index,
    required this.leafOwner,
    required this.previousDelegate,
    required this.newDelegate,
    required this.merkleTree,
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

  /// The previous delegate (if any).
  final Address previousDelegate;

  /// The new delegate address.
  final Address newDelegate;

  /// The address of the Merkle tree.
  final Address merkleTree;
}

/// Configuration for [getDelegateInstructionPlan].
class DelegateConfig {
  const DelegateConfig({
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

/// Creates an instruction plan that delegates a compressed NFT.
///
/// Delegates the asset to another address, allowing the delegate to
/// perform authorized actions on behalf of the owner.
///
/// ```dart
/// final plan = getDelegateInstructionPlan(
///   DelegateInput(
///     root: proof.root,
///     dataHash: proof.dataHash,
///     creatorHash: proof.creatorHash,
///     nonce: proof.nonce,
///     index: proof.index,
///     leafOwner: ownerAddress,
///     previousDelegate: ownerAddress,
///     newDelegate: delegateAddress,
///     merkleTree: treeAddress,
///   ),
/// );
/// ```
InstructionPlan getDelegateInstructionPlan(
  DelegateInput input, [
  DelegateConfig config = const DelegateConfig(),
]) {
  final logWrapper =
      config.logWrapper ?? const Address('noopb9bkMVz3tFhZ5L7bJGby9DreGG5J2P4V4Wxe8tK');
  final compressionProgram =
      config.compressionProgram ?? const Address('cmtDvXzGgh4bcrDY2gZqFaGQqat4RNQPhKJ4jAc7uLi');
  final systemProgram =
      config.systemProgram ?? const Address('11111111111111111111111111111112');

  return sequentialInstructionPlan([
    getDelegateInstruction(
      programAddress: mplBubblegumProgramAddressObject,
      treeAuthority: input.merkleTree,
      leafOwner: input.leafOwner,
      previousLeafDelegate: input.previousDelegate,
      newLeafDelegate: input.newDelegate,
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
