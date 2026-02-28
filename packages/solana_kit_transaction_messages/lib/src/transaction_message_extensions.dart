import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/blockhash.dart';
import 'package:solana_kit_transaction_messages/src/durable_nonce.dart';
import 'package:solana_kit_transaction_messages/src/fee_payer.dart';
import 'package:solana_kit_transaction_messages/src/instructions.dart';
import 'package:solana_kit_transaction_messages/src/lifetime.dart';
import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Fluent, Dart-idiomatic helpers for composing [TransactionMessage] values.
///
/// These methods are additive convenience wrappers around the existing
/// function-based APIs, enabling concise immutable chains such as:
///
/// ```dart
/// final message = createTransactionMessage(version: TransactionVersion.v0)
///     .withFeePayer(feePayer)
///     .withBlockhashLifetime(blockhashLifetime)
///     .appendInstruction(instruction);
/// ```
extension TransactionMessageFluentX on TransactionMessage {
  /// Returns a copy with [feePayer] set.
  TransactionMessage withFeePayer(Address feePayer) {
    return setTransactionMessageFeePayer(feePayer, this);
  }

  /// Returns a copy with [lifetime] set as blockhash lifetime.
  TransactionMessage withBlockhashLifetime(
    BlockhashLifetimeConstraint lifetime,
  ) {
    return setTransactionMessageLifetimeUsingBlockhash(lifetime, this);
  }

  /// Returns a copy with [config] applied as durable nonce lifetime.
  TransactionMessage withDurableNonceLifetime(DurableNonceConfig config) {
    return setTransactionMessageLifetimeUsingDurableNonce(config, this);
  }

  /// Returns a copy with [instruction] appended.
  TransactionMessage appendInstruction(Instruction instruction) {
    return appendTransactionMessageInstruction(instruction, this);
  }

  /// Returns a copy with [instructions] appended.
  TransactionMessage appendInstructions(Iterable<Instruction> instructions) {
    return appendTransactionMessageInstructions(
      List<Instruction>.unmodifiable(instructions),
      this,
    );
  }

  /// Returns a copy with [instruction] prepended.
  TransactionMessage prependInstruction(Instruction instruction) {
    return prependTransactionMessageInstruction(instruction, this);
  }

  /// Returns a copy with [instructions] prepended.
  TransactionMessage prependInstructions(Iterable<Instruction> instructions) {
    return prependTransactionMessageInstructions(
      List<Instruction>.unmodifiable(instructions),
      this,
    );
  }
}
