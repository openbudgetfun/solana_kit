import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/lifetime.dart';

/// Transaction version type.
enum TransactionVersion {
  /// A legacy (unversioned) transaction.
  legacy,

  /// A version 0 transaction.
  v0;

  /// The numeric value for versioned messages (0 for v0).
  /// Legacy has no numeric version.
  int? get versionNumber => this == legacy ? null : 0;
}

/// The maximum supported transaction version.
const maxSupportedTransactionVersion = 0;

/// A transaction message that can be built step by step.
///
/// All transform functions return new instances (immutable pattern).
class TransactionMessage {
  /// Creates a [TransactionMessage] with the given parameters.
  const TransactionMessage({
    required this.version,
    this.instructions = const [],
    this.feePayer,
    this.lifetimeConstraint,
  });

  /// The version of this transaction message.
  final TransactionVersion version;

  /// The instructions in this transaction message.
  final List<Instruction> instructions;

  /// The fee payer address for this transaction message.
  final Address? feePayer;

  /// The lifetime constraint for this transaction message.
  final LifetimeConstraint? lifetimeConstraint;

  /// Creates a copy of this [TransactionMessage] with the given fields
  /// replaced.
  TransactionMessage copyWith({
    TransactionVersion? version,
    List<Instruction>? instructions,
    Address? feePayer,
    bool clearFeePayer = false,
    LifetimeConstraint? lifetimeConstraint,
    bool clearLifetimeConstraint = false,
  }) => TransactionMessage(
    version: version ?? this.version,
    instructions: instructions != null
        ? List<Instruction>.unmodifiable(instructions)
        : this.instructions,
    feePayer: clearFeePayer ? null : (feePayer ?? this.feePayer),
    lifetimeConstraint: clearLifetimeConstraint
        ? null
        : (lifetimeConstraint ?? this.lifetimeConstraint),
  );
}
