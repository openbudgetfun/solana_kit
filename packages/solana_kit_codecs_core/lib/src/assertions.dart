import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Asserts that the byte array is not empty after the optional [offset].
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.codecsCannotDecodeEmptyByteArray] if the byte array has
/// no bytes remaining after [offset].
void assertByteArrayIsNotEmptyForCodec(
  String codecDescription,
  Uint8List bytes, [
  int offset = 0,
]) {
  if (bytes.length - offset <= 0) {
    throw SolanaError(SolanaErrorCode.codecsCannotDecodeEmptyByteArray, {
      'codecDescription': codecDescription,
    });
  }
}

/// Asserts that the byte array has at least [expected] bytes remaining after
/// [offset].
///
/// Throws a [SolanaError] with code [SolanaErrorCode.codecsInvalidByteLength]
/// if there are not enough bytes.
void assertByteArrayHasEnoughBytesForCodec(
  String codecDescription,
  int expected,
  Uint8List bytes, [
  int offset = 0,
]) {
  final bytesLength = bytes.length - offset;
  if (bytesLength < expected) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'bytesLength': bytesLength,
      'codecDescription': codecDescription,
      'expected': expected,
    });
  }
}

/// Asserts that [offset] is within the valid range `[0, bytesLength]`.
///
/// An offset equal to [bytesLength] is considered valid (end of array).
///
/// Throws a [SolanaError] with code [SolanaErrorCode.codecsOffsetOutOfRange]
/// if [offset] is out of range.
void assertByteArrayOffsetIsNotOutOfRange(
  String codecDescription,
  int offset,
  int bytesLength,
) {
  if (offset < 0 || offset > bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsOffsetOutOfRange, {
      'bytesLength': bytesLength,
      'codecDescription': codecDescription,
      'offset': offset,
    });
  }
}
