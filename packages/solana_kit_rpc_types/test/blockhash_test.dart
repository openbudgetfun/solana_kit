import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsBlockhash()', () {
    test('throws when supplied a non-base58 string', () {
      // This string is 41 chars (within 32-44 range) but contains
      // invalid base58 chars (hyphens), so it throws a codec error.
      expect(
        () => assertIsBlockhash('not-a-base-58-encoded-string-but-nice-try'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsInvalidStringForBase,
          ),
        ),
      );
    });

    test('throws when the encoded string is of length 31', () {
      expect(
        () => assertIsBlockhash('1' * 31),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.blockhashStringLengthOutOfRange,
          ),
        ),
      );
    });

    test('throws when the encoded string is of length 45', () {
      expect(
        () => assertIsBlockhash('1' * 45),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.blockhashStringLengthOutOfRange,
          ),
        ),
      );
    });

    test('throws when the decoded byte array has a length of 31 bytes', () {
      // 31-byte decoded value
      expect(
        () => assertIsBlockhash('tVojvhToWjQ8Xvo4UPx2Xz9eRy7auyYMmZBjc2XfN'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.invalidBlockhashByteLength,
          ),
        ),
      );
    });

    test('throws when the decoded byte array has a length of 33 bytes', () {
      expect(
        () => assertIsBlockhash('JJEfe6DcPM2ziB2vfUWDV6aHVerXRGkv3TcyvJUNGHZz'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.invalidBlockhashByteLength,
          ),
        ),
      );
    });

    test('does not throw when supplied a base-58 encoded hash', () {
      expect(
        () => assertIsBlockhash('11111111111111111111111111111111'),
        returnsNormally,
      );
    });
  });

  group('isBlockhash()', () {
    test('returns true for a valid blockhash', () {
      expect(isBlockhash('11111111111111111111111111111111'), isTrue);
    });

    test('returns false for a too-short string', () {
      expect(isBlockhash('1' * 31), isFalse);
    });

    test('returns false for a too-long string', () {
      expect(isBlockhash('1' * 45), isFalse);
    });

    test('returns false for a non-base58 string', () {
      expect(isBlockhash('not-a-base-58-encoded-string'), isFalse);
    });
  });

  group('blockhash()', () {
    test('creates a Blockhash from a valid string', () {
      const hash = '11111111111111111111111111111111';
      final bh = blockhash(hash);
      expect(bh.value, equals(hash));
    });

    test('throws for an invalid string', () {
      expect(() => blockhash('invalid'), throwsA(isA<SolanaError>()));
    });
  });

  group('getBlockhashCodec()', () {
    late FixedSizeCodec<Blockhash, Blockhash> codec;

    setUp(() {
      codec = getBlockhashCodec();
    });

    test('serializes a base58 encoded blockhash into a 32-byte buffer', () {
      const bh = Blockhash('4wBqpZM9xaSheZzJSMawUHDgZ7miWfSsxmfVF5jJpYP');
      expect(
        codec.encode(bh),
        equals(
          Uint8List.fromList([
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, //
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
          ]),
        ),
      );
    });

    test('deserializes a byte buffer representing a blockhash '
        'into a base58 encoded blockhash', () {
      final bytes = Uint8List.fromList([
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, //
        17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,
        // Extra bytes not part of the blockhash
        33, 34,
      ]);
      expect(
        codec.decode(bytes),
        equals(const Blockhash('4wBqpZM9xaSheZzJSMawUKKwhdpChKbZ5eu5ky4Vigw')),
      );
    });

    test(
      'fatals when trying to deserialize a byte buffer shorter than 32 bytes',
      () {
        final tooShortBuffer = Uint8List(31);
        expect(
          () => codec.decode(tooShortBuffer),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.codecsInvalidByteLength,
            ),
          ),
        );
      },
    );
  });

  group('getBlockhashComparator()', () {
    test('sorts base 58 blockhashes', () {
      final input = [
        'Ht1VrhoyhwMGMpBBi89BPdJp5R39Mu49suKx3A22W9Qs',
        'J9ZSLc9qPg3FR8UqfN6ae1QkVReUmnpLgQqFkGEPqmod',
        '6JYSQqSHY1E5JDwEfgWMieozqA1KCwiP2cH69to9eWKH',
        '7YR1xA7yzFAT4yQCsS4rpowjU1tsh5YUJd9hWMHRppcX',
        '7grJ9YUAEHxckLFqCY7fq8cM1UrragNSuPH1dvwJ8EEK',
        'AJBPNWCjVLwxff2eJynW56cMRCGmyU4y3vbuvtVdgVgb',
        'B8A2zUEDtJjR7nrokNUJYhgUQiwEBzC88rZc6WUE5ZeF',
        'BKggsVVp7yLmXtPuBDtC3FXBzvLyyye3Q2tFKUUGCHLj',
        'Ds72joawSKQ9nCDAAmGMKFiwiY6HR7PDzYDHDzZom3tj',
        'F1zKr4ZUYo5UAnH1fvYaD6R7ne137NYfS1r5HrCb8NpF',
      ]..sort(getBlockhashComparator());

      expect(input, [
        '6JYSQqSHY1E5JDwEfgWMieozqA1KCwiP2cH69to9eWKH',
        '7grJ9YUAEHxckLFqCY7fq8cM1UrragNSuPH1dvwJ8EEK',
        '7YR1xA7yzFAT4yQCsS4rpowjU1tsh5YUJd9hWMHRppcX',
        'AJBPNWCjVLwxff2eJynW56cMRCGmyU4y3vbuvtVdgVgb',
        'B8A2zUEDtJjR7nrokNUJYhgUQiwEBzC88rZc6WUE5ZeF',
        'BKggsVVp7yLmXtPuBDtC3FXBzvLyyye3Q2tFKUUGCHLj',
        'Ds72joawSKQ9nCDAAmGMKFiwiY6HR7PDzYDHDzZom3tj',
        'F1zKr4ZUYo5UAnH1fvYaD6R7ne137NYfS1r5HrCb8NpF',
        'Ht1VrhoyhwMGMpBBi89BPdJp5R39Mu49suKx3A22W9Qs',
        'J9ZSLc9qPg3FR8UqfN6ae1QkVReUmnpLgQqFkGEPqmod',
      ]);
    });
  });
}
