import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

/// Encode hex string to [Uint8List].
Uint8List b(String hex) {
  final matches = RegExp('.{1,2}').allMatches(hex.toLowerCase());
  return Uint8List.fromList(
    matches.map((m) => int.parse(m.group(0)!, radix: 16)).toList(),
  );
}

/// Decode [Uint8List] to lowercase hex string.
String h(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

/// Assert that encoding [number] with [codec] produces [hexBytes], and
/// decoding [hexBytes] produces [decodedNumber] (or [number] cast to the
/// decode type, if not specified).
///
/// Works for [FixedSizeCodec<num, int>] (integer codecs).
void assertValidInt(
  FixedSizeCodec<num, int> codec,
  num number,
  String hexBytes, [
  int? decodedNumber,
]) {
  // Encode
  final actualBytes = codec.encode(number);
  expect(h(actualBytes), equals(hexBytes));

  // Decode
  final (value, offset) = codec.read(actualBytes, 0);
  expect(value, equals(decodedNumber ?? number.toInt()));
  expect(offset, equals(actualBytes.length));

  // Decode with prefix offset
  final prefixedBytes = b('ffffff$hexBytes');
  final (value2, offset2) = codec.read(prefixedBytes, 3);
  expect(value2, equals(decodedNumber ?? number.toInt()));
  expect(offset2, equals(actualBytes.length + 3));
}

/// Assert that encoding [number] with [codec] produces [hexBytes], and
/// decoding [hexBytes] produces [decodedNumber] (or [number] if not
/// specified).
///
/// Works for [FixedSizeCodec<BigInt, BigInt>] (64-bit and 128-bit codecs).
void assertValidBigInt(
  FixedSizeCodec<BigInt, BigInt> codec,
  BigInt number,
  String hexBytes, [
  BigInt? decodedNumber,
]) {
  // Encode
  final actualBytes = codec.encode(number);
  expect(h(actualBytes), equals(hexBytes));

  // Decode
  final (value, offset) = codec.read(actualBytes, 0);
  expect(value, equals(decodedNumber ?? number));
  expect(offset, equals(actualBytes.length));

  // Decode with prefix offset
  final prefixedBytes = b('ffffff$hexBytes');
  final (value2, offset2) = codec.read(prefixedBytes, 3);
  expect(value2, equals(decodedNumber ?? number));
  expect(offset2, equals(actualBytes.length + 3));
}

/// Assert that encoding [number] with [codec] produces [hexBytes], and
/// decoding [hexBytes] produces [decodedNumber] (or [number] as double if
/// not specified).
///
/// Works for [FixedSizeCodec<num, double>] (float codecs).
void assertValidFloat(
  FixedSizeCodec<num, double> codec,
  num number,
  String hexBytes, [
  double? decodedNumber,
]) {
  // Encode
  final actualBytes = codec.encode(number);
  expect(h(actualBytes), equals(hexBytes));

  // Decode
  final (value, offset) = codec.read(actualBytes, 0);
  expect(value, equals(decodedNumber ?? number.toDouble()));
  expect(offset, equals(actualBytes.length));

  // Decode with prefix offset
  final prefixedBytes = b('ffffff$hexBytes');
  final (value2, offset2) = codec.read(prefixedBytes, 3);
  expect(value2, equals(decodedNumber ?? number.toDouble()));
  expect(offset2, equals(actualBytes.length + 3));
}

/// Assert that encoding [number] with the [encoder] produces [hexBytes].
void assertValidEncode(Encoder<num> encoder, num number, String hexBytes) {
  final actualBytes = encoder.encode(number);
  expect(h(actualBytes), equals(hexBytes));
}

/// Assert that encoding [value] with the [encoder] produces [hexBytes]
/// (BigInt variant).
void assertValidEncodeBigInt(
  Encoder<BigInt> encoder,
  BigInt value,
  String hexBytes,
) {
  final actualBytes = encoder.encode(value);
  expect(h(actualBytes), equals(hexBytes));
}

/// Assert that encoding [value] with [encoder] throws a [SolanaError] with
/// code [SolanaErrorCode.codecsNumberOutOfRange].
void assertRangeError(Encoder<num> encoder, num value) {
  expect(
    () => encoder.encode(value),
    throwsA(
      isA<SolanaError>().having(
        (e) => e.code,
        'code',
        equals(SolanaErrorCode.codecsNumberOutOfRange),
      ),
    ),
  );
}

/// Assert that encoding [value] (BigInt) with [encoder] throws a
/// [SolanaError] with code [SolanaErrorCode.codecsNumberOutOfRange].
void assertRangeErrorBigInt(Encoder<BigInt> encoder, BigInt value) {
  expect(
    () => encoder.encode(value),
    throwsA(
      isA<SolanaError>().having(
        (e) => e.code,
        'code',
        equals(SolanaErrorCode.codecsNumberOutOfRange),
      ),
    ),
  );
}
