import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

/// Returns a new transaction message with the given [instruction] appended
/// to the end of the instructions list.
TransactionMessage appendTransactionMessageInstruction(
  Instruction instruction,
  TransactionMessage message,
) => appendTransactionMessageInstructions([instruction], message);

/// Returns a new transaction message with the given [instructions] appended
/// to the end of the instructions list.
TransactionMessage appendTransactionMessageInstructions(
  List<Instruction> instructions,
  TransactionMessage message,
) => message.copyWith(
  instructions: List<Instruction>.unmodifiable([
    ...message.instructions,
    ...instructions,
  ]),
);

/// Returns a new transaction message with the given [instruction] prepended
/// to the beginning of the instructions list.
TransactionMessage prependTransactionMessageInstruction(
  Instruction instruction,
  TransactionMessage message,
) => prependTransactionMessageInstructions([instruction], message);

/// Returns a new transaction message with the given [instructions] prepended
/// to the beginning of the instructions list.
TransactionMessage prependTransactionMessageInstructions(
  List<Instruction> instructions,
  TransactionMessage message,
) => message.copyWith(
  instructions: List<Instruction>.unmodifiable([
    ...instructions,
    ...message.instructions,
  ]),
);
