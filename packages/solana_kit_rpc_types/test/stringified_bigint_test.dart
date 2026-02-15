import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsStringifiedBigInt()', () {
    test("throws when supplied a string that can't parse as a number", () {
      expect(
        () => assertIsStringifiedBigInt('abc'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedBigintString,
          ),
        ),
      );
      expect(
        () => assertIsStringifiedBigInt('123a'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedBigintString,
          ),
        ),
      );
    });

    test("throws when supplied a string that can't parse as an integer", () {
      expect(
        () => assertIsStringifiedBigInt('123.0'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedBigintString,
          ),
        ),
      );
      expect(
        () => assertIsStringifiedBigInt('123.5'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedBigintString,
          ),
        ),
      );
    });

    test('does not throw when supplied a string that parses as an integer', () {
      expect(() => assertIsStringifiedBigInt('-123'), returnsNormally);
      expect(() => assertIsStringifiedBigInt('0'), returnsNormally);
      expect(() => assertIsStringifiedBigInt('123'), returnsNormally);
    });
  });

  group('isStringifiedBigInt()', () {
    test('returns true for valid integer strings', () {
      expect(isStringifiedBigInt('0'), isTrue);
      expect(isStringifiedBigInt('123'), isTrue);
      expect(isStringifiedBigInt('-456'), isTrue);
    });

    test('returns false for non-integer strings', () {
      expect(isStringifiedBigInt('abc'), isFalse);
      expect(isStringifiedBigInt('123.5'), isFalse);
      expect(isStringifiedBigInt(''), isFalse);
    });
  });

  group('stringifiedBigInt()', () {
    test('can coerce to StringifiedBigInt', () {
      final coerced = stringifiedBigInt('1234');
      expect(coerced.value, equals('1234'));
    });

    test('throws on invalid StringifiedBigInt', () {
      expect(
        () => stringifiedBigInt('test'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedBigintString,
          ),
        ),
      );
    });
  });
}
