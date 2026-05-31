/// Composite helper for burning a compressed NFT.
library;

import 'package:solana_kit_addresses/solana_kit_addresses.dart'
    hide
        noopProgramAddress,
        splAccountCompressionProgramAddress,
        systemProgramAddress,
        tokenProgramAddress;
import 'package:solana_kit_instruction_plans/solana_kit_instruction_plans.dart';
import 'package:solana_kit_mpl_bubblegum/src/constants/program_addresses.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/instructions/burn.dart';
import 'package:solana_kit_mpl_bubblegum/src/generated/programs/mpl_bubblegum.dart';

/// Input for burning a compressed NFT.
/// Input for BurnInput.
class BurnInput {
  /// Creates a [BurnInput].
  const BurnInput({
    required this.root,
    required this.dataHash,
    required this.creatorHash,
    required this.nonce,
    required this.index,
    required this.leafOwner,
    required this.leafDelegate,
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

  /// The delegate of the compressed NFT (if delegated).
  final Address leafDelegate;

  /// The address of the Merkle tree.
  final Address merkleTree;
}

/// Configuration for [getBurnInstructionPlan].
/// Configuration for BurnConfig.
class BurnConfig {
  /// Creates a [BurnConfig].
  const BurnConfig({
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

/// Creates an instruction plan that burns a compressed NFT.
///
/// Burns the asset, removing it from circulation. The transaction must be
/// signed by either the leaf owner or leaf delegate.
///
/// ```dart
/// final plan = getBurnInstructionPlan(
///   BurnInput(
///     root: proof.root,
///     dataHash: proof.dataHash,
///     creatorHash: proof.creatorHash,
///     nonce: proof.nonce,
///     index: proof.index,
///     leafOwner: ownerAddress,
///     leafDelegate: ownerAddress,
///     merkleTree: treeAddress,
///   ),
/// );
/// ```
InstructionPlan getBurnInstructionPlan(
  BurnInput input, [
  BurnConfig config = const BurnConfig(),
]) {
  final logWrapper = config.logWrapper ?? noopProgramAddress;
  final compressionProgram =
      config.compressionProgram ?? splAccountCompressionProgramAddress;
  final systemProgram = config.systemProgram ?? systemProgramAddress;

  return sequentialInstructionPlan([
    getBurnInstruction(
      programAddress: mplBubblegumProgramAddressObject,
      treeAuthority: input.merkleTree,
      leafOwner: input.leafOwner,
      leafDelegate: input.leafDelegate,
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
