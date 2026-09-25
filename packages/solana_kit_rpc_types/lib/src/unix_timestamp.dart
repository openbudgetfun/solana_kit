import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Represents a Unix timestamp in seconds.
///
/// It is represented as a [BigInt] in client code and an `i64` in server code.
extension type const UnixTimestamp(BigInt value) implements Object {}

/// Largest possible value to be represented by an i64.
final BigInt _maxI64Value = BigInt.parse('9223372036854775807'); // 2^63 - 1

/// Smallest possible value to be represented by an i64.
final BigInt _minI64Value = BigInt.parse('-9223372036854775808'); // -(2^63)

/// Returns `true` if [putativeTimestamp] is within the i64 range and thus
/// a valid [UnixTimestamp].
bool isUnixTimestamp(BigInt putativeTimestamp) {
  return putativeTimestamp >= _minI64Value && putativeTimestamp <= _maxI64Value;
}

/// Asserts that [putativeTimestamp] is a valid [UnixTimestamp] within the i64
/// range.
///
/// Throws a [SolanaError] with code [SolanaErrorCode.timestampOutOfRange] if
/// the value is outside the valid range.
void assertIsUnixTimestamp(BigInt putativeTimestamp) {
  if (putativeTimestamp < _minI64Value || putativeTimestamp > _maxI64Value) {
    throw SolanaError(SolanaErrorCode.timestampOutOfRange, {
      'value': putativeTimestamp,
    });
  }
}

/// Combines asserting that a [BigInt] represents a Unix timestamp with
/// coercing it to the [UnixTimestamp] type. It's best used with untrusted
/// input.
UnixTimestamp unixTimestamp(BigInt putativeTimestamp) {
  assertIsUnixTimestamp(putativeTimestamp);
  return UnixTimestamp(putativeTimestamp);
}
