import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('coercions', () {
    group('lamports', () {
      test('can coerce to Lamports', () {
        final coerced = lamports(BigInt.from(1234));
        expect(coerced.value, equals(BigInt.from(1234)));
      });

      test('throws on invalid Lamports', () {
        expect(
          () => lamports(-BigInt.from(5)),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.lamportsOutOfRange,
            ),
          ),
        );
      });
    });

    group('stringifiedBigInt', () {
      test('can coerce to StringifiedBigInt', () {
        final coerced = stringifiedBigInt('1234');
        expect(coerced, equals('1234'));
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

    group('stringifiedNumber', () {
      test('can coerce to StringifiedNumber', () {
        final coerced = stringifiedNumber('1234');
        expect(coerced, equals('1234'));
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

    group('unixTimestamp', () {
      test('can coerce to UnixTimestamp', () {
        final coerced = unixTimestamp(BigInt.from(1234));
        expect(coerced.value, equals(BigInt.from(1234)));
      });

      test('throws on an out-of-range UnixTimestamp', () {
        expect(
          () => unixTimestamp(BigInt.two.pow(63)),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode.timestampOutOfRange,
            ),
          ),
        );
      });
    });
  });
}
