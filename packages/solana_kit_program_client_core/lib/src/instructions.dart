import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// An instruction that tracks how many bytes it adds or removes from on-chain
/// accounts.
///
/// The [byteDelta] indicates the net change in account storage size. A positive
/// value means bytes are being allocated, while a negative value means bytes
/// are being freed. This is useful for calculating how much balance a storage
/// payer must have for a transaction to succeed.
class InstructionWithByteDelta extends Instruction {
  /// Creates an [InstructionWithByteDelta].
  const InstructionWithByteDelta({
    required super.programAddress,
    required this.byteDelta,
    super.accounts,
    super.data,
  });

  /// The net change in account storage size in bytes.
  ///
  /// A positive value means bytes are being allocated, while a negative value
  /// means bytes are being freed.
  final int byteDelta;
}
