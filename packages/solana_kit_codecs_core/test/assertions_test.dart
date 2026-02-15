import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('assertByteArrayIsNotEmptyForCodec', () {
    test('throws when the byte array is empty', () {
      expect(
        () => assertByteArrayIsNotEmptyForCodec('testCodec', Uint8List(0)),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsCannotDecodeEmptyByteArray,
          ),
        ),
      );
    });

    test('throws when the byte array is empty after offset', () {
      expect(
        () => assertByteArrayIsNotEmptyForCodec(
          'testCodec',
          Uint8List.fromList([1, 2, 3]),
          3,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsCannotDecodeEmptyByteArray,
          ),
        ),
      );
    });

    test('passes when the byte array is not empty', () {
      expect(
        () => assertByteArrayIsNotEmptyForCodec(
          'testCodec',
          Uint8List.fromList([1]),
        ),
        returnsNormally,
      );
    });

    test('passes when the byte array has bytes remaining after offset', () {
      expect(
        () => assertByteArrayIsNotEmptyForCodec(
          'testCodec',
          Uint8List.fromList([1, 2, 3]),
          2,
        ),
        returnsNormally,
      );
    });
  });

  group('assertByteArrayHasEnoughBytesForCodec', () {
    test('throws when there are not enough bytes', () {
      expect(
        () => assertByteArrayHasEnoughBytesForCodec(
          'testCodec',
          10,
          Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsInvalidByteLength,
          ),
        ),
      );
    });

    test('throws when there are not enough bytes after offset', () {
      expect(
        () => assertByteArrayHasEnoughBytesForCodec(
          'testCodec',
          5,
          Uint8List.fromList([1, 2, 3, 4, 5, 6]),
          3,
        ),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsInvalidByteLength,
          ),
        ),
      );
    });

    test('passes when there are enough bytes', () {
      expect(
        () => assertByteArrayHasEnoughBytesForCodec(
          'testCodec',
          3,
          Uint8List.fromList([1, 2, 3]),
        ),
        returnsNormally,
      );
    });

    test('passes when there are more than enough bytes', () {
      expect(
        () => assertByteArrayHasEnoughBytesForCodec(
          'testCodec',
          3,
          Uint8List.fromList([1, 2, 3, 4, 5]),
        ),
        returnsNormally,
      );
    });

    test('passes when there are enough bytes after offset', () {
      expect(
        () => assertByteArrayHasEnoughBytesForCodec(
          'testCodec',
          3,
          Uint8List.fromList([1, 2, 3, 4, 5]),
          2,
        ),
        returnsNormally,
      );
    });
  });

  group('assertByteArrayOffsetIsNotOutOfRange', () {
    test('throws when the offset is negative', () {
      expect(
        () => assertByteArrayOffsetIsNotOutOfRange('testCodec', -1, 10),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsOffsetOutOfRange,
          ),
        ),
      );
    });

    test('throws when the offset exceeds the byte array length', () {
      expect(
        () => assertByteArrayOffsetIsNotOutOfRange('testCodec', 11, 10),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsOffsetOutOfRange,
          ),
        ),
      );
    });

    test('passes when the offset is within range', () {
      expect(
        () => assertByteArrayOffsetIsNotOutOfRange('testCodec', 5, 10),
        returnsNormally,
      );
    });

    test('passes when the offset is zero', () {
      expect(
        () => assertByteArrayOffsetIsNotOutOfRange('testCodec', 0, 10),
        returnsNormally,
      );
    });

    test('passes when the offset equals the byte array length', () {
      // An offset equal to bytesLength is valid (end of array).
      expect(
        () => assertByteArrayOffsetIsNotOutOfRange('testCodec', 10, 10),
        returnsNormally,
      );
    });
  });
}
