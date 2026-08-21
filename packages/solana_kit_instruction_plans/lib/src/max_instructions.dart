import 'package:solana_kit_errors/solana_kit_errors.dart';

/// The default maximum number of top-level instructions per planned
/// transaction message.
///
/// This is intentionally lower than the transaction format's instruction limit
/// (see [transactionInstructionLimit]) to leave headroom for inner
/// instructions (CPIs), which are not visible at planning time.
///
/// Added in @solana/kit v7.0.0.
const int defaultMaxInstructionsPerTransaction = 16;

/// The hard maximum number of top-level instructions the transaction format
/// can encode.
///
/// Every current transaction version shares this limit. It is intentionally
/// duplicated here, rather than derived from `solana_kit_transactions`, so a
/// configured maximum can be validated without compiling a transaction
/// message. If a future transaction version raises the limit, update this
/// constant (and consider making it version-aware).
///
/// Added in @solana/kit v7.0.0.
const int transactionInstructionLimit = 64;

/// Resolves the effective maximum number of instructions allowed in a
/// transaction message.
///
/// Falls back to [defaultMaxInstructionsPerTransaction] when `null` is
/// provided. The provided value is expected to be a positive integer no
/// greater than the transaction format's instruction limit; validate it first
/// with [assertValidMaxInstructionsPerTransaction].
///
/// Added in @solana/kit v7.0.0.
int resolveMaxInstructions(int? maxInstructions) {
  return maxInstructions ?? defaultMaxInstructionsPerTransaction;
}

/// Asserts that a configured maximum number of instructions per transaction is
/// valid.
///
/// A configured maximum must be a positive integer no greater than the number
/// of top-level instructions the transaction format can encode (see
/// [transactionInstructionLimit]). Rejects values that are not positive
/// integers. `null` is allowed and falls back to the default.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.instructionPlansInvalidMaxInstructionsPerTransaction].
///
/// Added in @solana/kit v7.0.0.
void assertValidMaxInstructionsPerTransaction(int? maxInstructions) {
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
