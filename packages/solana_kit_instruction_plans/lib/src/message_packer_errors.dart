import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_instruction_plans/src/max_instructions.dart';

/// Resolves the maximum number of instructions a message packer may put in
/// a transaction message.
///
/// Falls back to [defaultMaxInstructionsPerTransaction] (16) when `null` is
/// provided, which leaves headroom for inner instructions (CPIs) that are
/// not visible at planning time. A provided value must be a positive integer
/// no greater than [transactionInstructionLimit] (64) — the number of
/// top-level instructions the transaction format can encode.
///
/// This is typically the first thing a custom message packer does with the
/// `maxInstructions` option it receives in `packMessageToCapacity`:
///
/// ```dart
/// packMessageToCapacity: (message, {maxInstructions}) {
///   final max = resolveMaxInstructionsPerTransaction(maxInstructions);
///   assertMaxInstructionsPerTransaction(message.instructions.length + 1, max);
///   // ...
/// }
/// ```
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansInvalidMaxInstructionsPerTransaction] if
/// the provided value is not a positive integer or exceeds the transaction
/// format's instruction limit.
///
/// Added in @solana/kit v8.4.0.
int resolveMaxInstructionsPerTransaction(int? maxInstructions) {
  if (maxInstructions != null &&
      (maxInstructions <= 0 || maxInstructions > transactionInstructionLimit)) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansInvalidMaxInstructionsPerTransaction,
      {
        'maxInstructions': maxInstructions,
        'transactionInstructionLimit': transactionInstructionLimit,
      },
    );
  }
  return maxInstructions ?? defaultMaxInstructionsPerTransaction;
}

/// Throws if [numInstructions] exceeds [maxInstructions].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansMaxInstructionsPerTransactionExceeded].
///
/// Added in @solana/kit v7.0.0.
void assertMaxInstructionsPerTransaction(
  int numInstructions,
  int maxInstructions,
) {
  if (numInstructions > maxInstructions) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansMaxInstructionsPerTransactionExceeded,
      {'maxInstructions': maxInstructions, 'numInstructions': numInstructions},
    );
  }
}

/// Asserts that a transaction message can grow from [currentSize] to
/// [nextSize] bytes without exceeding [sizeLimit].
///
/// Use it in a custom message packer after appending the next instruction(s)
/// to the message so the transaction planner knows to pack them into another
/// transaction message. It works on sizes rather than messages so that
/// callers who already computed them do not pay for it twice.
///
/// ```dart
/// final nextMessage = appendTransactionMessageInstruction(
///   nextInstruction,
///   message,
/// );
/// assertMessageCanAccommodateSize(
///   currentSize: getTransactionMessageSize(message),
///   nextSize: getTransactionMessageSize(nextMessage),
///   sizeLimit: getTransactionMessageSizeLimit(nextMessage),
/// );
/// return nextMessage;
/// ```
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan] if
/// [nextSize] exceeds [sizeLimit]. The error reports how many bytes were
/// required and how many were free.
///
/// Added in @solana/kit v8.4.0.
void assertMessageCanAccommodateSize({
  required int currentSize,
  required int nextSize,
  required int sizeLimit,
}) {
  if (nextSize > sizeLimit) {
    throw SolanaError(
      SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
      {
        'numBytesRequired': nextSize - currentSize,
        'numFreeBytes': sizeLimit - currentSize,
      },
    );
  }
}

/// Identifies whether an error thrown whilst packing instructions into a
/// transaction message means that the message cannot take the instruction(s)
/// and that a new candidate message is required.
///
/// This is the set of errors the transaction planner treats as "try another
/// message": the message is too large
/// ([SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan]), holds
/// too many instructions
/// ([SolanaErrorCode.instructionPlansMaxInstructionsPerTransactionExceeded]),
/// references too many accounts or signers, or was rejected by a
/// message packer for a custom reason
/// ([SolanaErrorCode.instructionPlansMessageRejectedByPacker]). Any other
/// error is unexpected and should propagate.
///
/// ```dart
/// try {
///   message = messagePacker.packMessageToCapacity(message);
/// } on Object catch (error) {
///   if (!isMessagePackerErrorThatRequiresNewCandidate(error)) rethrow;
///   // The current transaction message cannot be used to pack this plan.
///   // Create a new one and try again.
///   message = messagePacker.packMessageToCapacity(createNewMessage());
/// }
/// ```
///
/// Added in @solana/kit v8.4.0.
bool isMessagePackerErrorThatRequiresNewCandidate(Object error) {
  return error is SolanaError &&
      const <SolanaErrorCode>{
        SolanaErrorCode.instructionPlansMaxInstructionsPerTransactionExceeded,
        SolanaErrorCode.instructionPlansMessageCannotAccommodatePlan,
        SolanaErrorCode.instructionPlansMessageRejectedByPacker,
        SolanaErrorCode.transactionTooManyAccountAddresses,
        SolanaErrorCode.transactionTooManyAccountsInInstruction,
        SolanaErrorCode.transactionTooManyInstructions,
        SolanaErrorCode.transactionTooManySignerAddresses,
      }.contains(error.code);
}
