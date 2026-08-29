import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_transaction_messages/src/compute_unit_limit.dart';

/// The smallest heap frame size that a transaction may request (32 KiB).
const int minHeapSize = 32 * 1024;

/// The largest heap frame size that a transaction may request (256 KiB).
const int maxHeapSize = 256 * 1024;

/// A requested heap frame size must be a whole number of KiB.
const int heapSizeMultipleOf = 1024;

/// Throws if the given compute unit limit is one the runtime will not honor as
/// written.
///
/// A transaction may request at most [maxComputeUnitLimit] compute units.
/// Requesting more does not fail the transaction; the runtime clamps the
/// request down to that maximum, so the budget the transaction runs with is
/// silently not the one that was asked for. Failing here surfaces both hazards
/// at the point the value is set.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionComputeUnitLimitOutOfRange] if the limit is
/// negative or greater than [maxComputeUnitLimit]. Dart integers are always
/// whole numbers, so the upstream "must be an integer" check reduces to the
/// range check.
///
/// Added in @solana/kit v8.1.0 (#1972).
void assertIsValidComputeUnitLimit(int computeUnitLimit) {
  if (computeUnitLimit < 0 || computeUnitLimit > maxComputeUnitLimit) {
    throw SolanaError(
      SolanaErrorCode.transactionComputeUnitLimitOutOfRange,
      {
        'computeUnitLimit': computeUnitLimit,
        'maxComputeUnitLimit': maxComputeUnitLimit,
      },
    );
  }
}

/// Throws if the given heap frame size is one the runtime will not accept.
///
/// The requested heap size must be a multiple of [heapSizeMultipleOf] bytes and
/// lie between [minHeapSize] and [maxHeapSize] inclusive. This mirrors the
/// transaction sanitization check performed by the runtime.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionInvalidHeapSize] if the size is out of range or
/// is not a whole number of KiB.
///
/// Added in @solana/kit v8.1.0 (#1972).
void assertIsValidHeapSize(int heapSize) {
  if (heapSize < minHeapSize ||
      heapSize > maxHeapSize ||
      heapSize % heapSizeMultipleOf != 0) {
    throw SolanaError(SolanaErrorCode.transactionInvalidHeapSize, {
      'heapSize': heapSize,
      'maxHeapSize': maxHeapSize,
      'minHeapSize': minHeapSize,
      'multipleOf': heapSizeMultipleOf,
    });
  }
}
