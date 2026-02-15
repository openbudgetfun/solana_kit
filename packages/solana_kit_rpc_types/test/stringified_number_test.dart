import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsStringifiedNumber()', () {
    test("throws when supplied a string that can't parse as a number", () {
      expect(
        () => assertIsStringifiedNumber('abc'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedNumberString,
          ),
        ),
      );
      expect(
        () => assertIsStringifiedNumber('123a'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedNumberString,
          ),
        ),
      );
    });

    test('does not throw when supplied a string that parses as a float', () {
      expect(() => assertIsStringifiedNumber('123.0'), returnsNormally);
      expect(() => assertIsStringifiedNumber('123.5'), returnsNormally);
    });

    test('does not throw when supplied a string that parses as an integer', () {
      expect(() => assertIsStringifiedNumber('-123'), returnsNormally);
      expect(() => assertIsStringifiedNumber('0'), returnsNormally);
      expect(() => assertIsStringifiedNumber('123'), returnsNormally);
    });
  });

  group('isStringifiedNumber()', () {
    test('returns true for valid number strings', () {
      expect(isStringifiedNumber('0'), isTrue);
      expect(isStringifiedNumber('123'), isTrue);
      expect(isStringifiedNumber('-456'), isTrue);
      expect(isStringifiedNumber('123.5'), isTrue);
      expect(isStringifiedNumber('-42.1'), isTrue);
    });

    test('returns false for non-number strings', () {
      expect(isStringifiedNumber('abc'), isFalse);
      expect(isStringifiedNumber('123a'), isFalse);
    });
  });

  group('stringifiedNumber()', () {
    test('can coerce to StringifiedNumber', () {
      final coerced = stringifiedNumber('1234');
      expect(coerced.value, equals('1234'));
    });

    test('throws on invalid StringifiedNumber', () {
      expect(
        () => stringifiedNumber('test'),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.malformedNumberString,
          ),
        ),
      );
    });
  });
}
