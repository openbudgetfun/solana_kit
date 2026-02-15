import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('Address', () {
    group('address()', () {
      test('can coerce a valid base58 address string', () {
        const raw = 'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G';
        final coerced = address(raw);
        expect(coerced.value, equals(raw));
      });

      test('does not throw for a valid base58 address', () {
        expect(
          () => address('11111111111111111111111111111111'),
          returnsNormally,
        );
      });

      test('throws when string length is 31 (too short)', () {
        expect(
          () => address('3' * 31),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesStringLengthOutOfRange,
            ),
          ),
        );
      });

      test('throws when string length is 45 (too long)', () {
        expect(
          () => address('3' * 45),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesStringLengthOutOfRange,
            ),
          ),
        );
      });

      test('throws when address decodes to 31 bytes', () {
        // 31 bytes [128, ..., 128]
        expect(
          () => address('tVojvhToWjQ8Xvo4UPx2Xz9eRy7auyYMmZBjc2XfN'),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesInvalidByteLength,
            ),
          ),
        );
      });

      test('throws when address decodes to 33 bytes', () {
        expect(
          () => address('JJEfe6DcPM2ziB2vfUWDV6aHVerXRGkv3TcyvJUNGHZz'),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesInvalidByteLength,
            ),
          ),
        );
      });
    });

    group('isAddress()', () {
      test('returns true for a valid base58 address', () {
        expect(isAddress('11111111111111111111111111111111'), isTrue);
      });

      test('returns false for a non-base58 string', () {
        expect(isAddress('not-a-base-58-encoded-string'), isFalse);
      });

      test('returns false when the decoded byte array is not 32 bytes', () {
        // 31 bytes [128, ..., 128]
        expect(
          isAddress('2xea9jWJ9eca3dFiefTeSPP85c6qXqunCqL2h2JNffM'),
          isFalse,
        );
      });

      test('returns false for too-short strings', () {
        // 31 characters
        expect(isAddress('1111111111111111111111111111111'), isFalse);
      });

      test('returns false for too-long strings', () {
        // 45 characters
        expect(
          isAddress('1JEKNVnkbo3jma5nREBBJCDoXFVeKkD56V3xKrvRmWxFG'),
          isFalse,
        );
      });

      test('does not throw for invalid input', () {
        expect(
          () => isAddress('not-a-base-58-encoded-string'),
          returnsNormally,
        );
      });
    });

    group('assertIsAddress()', () {
      test('does not throw for a valid address', () {
        expect(
          () => assertIsAddress('11111111111111111111111111111111'),
          returnsNormally,
        );
      });

      test('throws for a string that is too short', () {
        expect(
          () => assertIsAddress('not-a-base-58-encoded-string'),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesStringLengthOutOfRange,
            ),
          ),
        );
      });

      test('throws when decoded byte array is not 32 bytes', () {
        // 31 bytes [128, ..., 128]
        expect(
          () => assertIsAddress('2xea9jWJ9eca3dFiefTeSPP85c6qXqunCqL2h2JNffM'),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.addressesInvalidByteLength,
            ),
          ),
        );
      });

      test('accepts addresses of all valid string lengths (32 to 44)', () {
        // The all-ones address (32 bytes of 0x00) is '1' * 32 characters
        expect(
          () => assertIsAddress('11111111111111111111111111111111'),
          returnsNormally,
        );
      });
    });
  });
}
