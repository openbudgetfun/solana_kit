import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// A Solana address represented as a validated base58-encoded string.
///
/// An [Address] wraps a [String] that has been validated to be a base58-encoded
/// representation of exactly 32 bytes. This is an extension type so it has zero
/// runtime overhead compared to a plain [String].
///
/// Use the [address] factory function to create an [Address] from an untrusted
/// string. For known-good strings you may use the `Address()` constructor
/// directly.
extension type const Address(String value) {}

/// Memoized base58 encoder instance.
VariableSizeEncoder<String>? _memoizedBase58Encoder;

/// Returns a memoized base58 encoder.
VariableSizeEncoder<String> _getBase58Encoder() {
  return _memoizedBase58Encoder ??= getBase58Encoder();
}

/// Creates an [Address] from a string, asserting that it is a valid
/// base58-encoded Solana address.
///
/// Throws a [SolanaError] if the string is not a valid address.
Address address(String putativeAddress) {
  assertIsAddress(putativeAddress);
  return Address(putativeAddress);
}

/// Asserts that [putativeAddress] is a valid base58-encoded Solana address.
///
/// A valid address has a string length between 32 and 44 characters and
/// decodes to exactly 32 bytes.
///
/// Throws [SolanaError] with [SolanaErrorCode.addressesStringLengthOutOfRange]
/// if the string length is outside [32, 44].
///
/// Throws [SolanaError] with [SolanaErrorCode.addressesInvalidByteLength]
/// if the decoded byte array is not exactly 32 bytes.
void assertIsAddress(String putativeAddress) {
  if (putativeAddress.length < 32 || putativeAddress.length > 44) {
    throw SolanaError(SolanaErrorCode.addressesStringLengthOutOfRange, {
      'actualLength': putativeAddress.length,
    });
  }

  final encoder = _getBase58Encoder();
  final bytes = encoder.encode(putativeAddress);
  final numBytes = bytes.length;

  if (numBytes != 32) {
    throw SolanaError(SolanaErrorCode.addressesInvalidByteLength, {
      'actualLength': numBytes,
    });
  }
}

/// Returns `true` if [putativeAddress] is a valid base58-encoded Solana
/// address.
///
/// Unlike [assertIsAddress], this function does not throw but returns `false`
/// for invalid addresses.
bool isAddress(String putativeAddress) {
  if (putativeAddress.length < 32 || putativeAddress.length > 44) {
    return false;
  }

  final encoder = _getBase58Encoder();
  try {
    return encoder.encode(putativeAddress).length == 32;
  } on Object {
    return false;
  }
}
