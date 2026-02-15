import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// A Solana blockhash represented as a validated base58-encoded string.
///
/// A [Blockhash] wraps a [String] that has been validated to be a
/// base58-encoded representation of exactly 32 bytes. This is an extension
/// type so it has zero runtime overhead compared to a plain [String].
///
/// Use the [blockhash] factory function to create a [Blockhash] from an
/// untrusted string.
extension type const Blockhash(String value) {}

/// Returns `true` if [putativeBlockhash] is a valid base58-encoded blockhash.
bool isBlockhash(String putativeBlockhash) {
  return isAddress(putativeBlockhash);
}

/// Asserts that [putativeBlockhash] is a valid base58-encoded blockhash.
///
/// A valid blockhash has the same format as an address: a string length
/// between 32 and 44 characters that decodes to exactly 32 bytes.
///
/// Throws [SolanaError] with [SolanaErrorCode.blockhashStringLengthOutOfRange]
/// if the string length is outside [32, 44].
///
/// Throws [SolanaError] with [SolanaErrorCode.invalidBlockhashByteLength]
/// if the decoded byte array is not exactly 32 bytes.
void assertIsBlockhash(String putativeBlockhash) {
  try {
    assertIsAddress(putativeBlockhash);
  } on SolanaError catch (error) {
    if (isSolanaError(error, SolanaErrorCode.addressesStringLengthOutOfRange)) {
      throw SolanaError(
        SolanaErrorCode.blockhashStringLengthOutOfRange,
        error.context,
      );
    }
    if (isSolanaError(error, SolanaErrorCode.addressesInvalidByteLength)) {
      throw SolanaError(
        SolanaErrorCode.invalidBlockhashByteLength,
        error.context,
      );
    }
    rethrow;
  }
}

/// Creates a [Blockhash] from a string, asserting that it is a valid
/// base58-encoded blockhash.
///
/// Throws a [SolanaError] if the string is not a valid blockhash.
Blockhash blockhash(String putativeBlockhash) {
  assertIsBlockhash(putativeBlockhash);
  return Blockhash(putativeBlockhash);
}

/// Returns a fixed-size encoder that encodes a base58-encoded blockhash
/// into exactly 32 bytes.
FixedSizeEncoder<Blockhash> getBlockhashEncoder() {
  final addressEncoder = getAddressEncoder();
  return transformEncoder<Address, Blockhash>(addressEncoder, (bh) {
        assertIsBlockhash(bh.value);
        return Address(bh.value);
      })
      as FixedSizeEncoder<Blockhash>;
}

/// Returns a fixed-size decoder that decodes exactly 32 bytes into a
/// base58-encoded [Blockhash].
FixedSizeDecoder<Blockhash> getBlockhashDecoder() {
  final addressDecoder = getAddressDecoder();
  return transformDecoder<Address, Blockhash>(
        addressDecoder,
        (value, bytes, offset) => Blockhash(value.value),
      )
      as FixedSizeDecoder<Blockhash>;
}

/// Returns a fixed-size codec that encodes and decodes [Blockhash] values
/// as exactly 32 bytes.
FixedSizeCodec<Blockhash, Blockhash> getBlockhashCodec() {
  return combineCodec(getBlockhashEncoder(), getBlockhashDecoder())
      as FixedSizeCodec<Blockhash, Blockhash>;
}

/// Returns a [Comparator] that sorts blockhash strings using base58
/// collation rules.
///
/// The comparator sorts blockhashes using a case-sensitive variant-aware
/// string comparison where lowercase letters sort before uppercase. This
/// matches the base58 alphabet ordering used by Solana.
Comparator<String> getBlockhashComparator() {
  return _compareBase58;
}

/// Compares two base58-encoded strings using character-by-character comparison
/// according to the base58 alphabet ordering.
int _compareBase58(String a, String b) {
  final minLen = a.length < b.length ? a.length : b.length;
  for (var i = 0; i < minLen; i++) {
    final charA = a.codeUnitAt(i);
    final charB = b.codeUnitAt(i);
    if (charA != charB) {
      final orderA = _charOrder(charA);
      final orderB = _charOrder(charB);
      return orderA.compareTo(orderB);
    }
  }
  return a.length.compareTo(b.length);
}

/// Returns a sort-order value for a character code following ICU collation
/// rules with caseFirst: 'lower' and sensitivity: 'variant'.
int _charOrder(int codeUnit) {
  // Digits 0-9 (codeUnits 48-57) sort first
  if (codeUnit >= 48 && codeUnit <= 57) {
    return codeUnit - 48; // 0-9
  }
  // Letters: lowercase before uppercase for same letter
  if (codeUnit >= 97 && codeUnit <= 122) {
    // lowercase letter: maps to (letter_index * 2 + 10)
    return (codeUnit - 97) * 2 + 10;
  }
  if (codeUnit >= 65 && codeUnit <= 90) {
    // uppercase letter: maps to (letter_index * 2 + 11)
    return (codeUnit - 65) * 2 + 11;
  }
  // Fallback for non-alphanumeric characters
  return codeUnit + 100;
}
