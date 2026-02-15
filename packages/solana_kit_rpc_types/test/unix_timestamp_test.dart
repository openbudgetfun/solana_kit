import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('assertIsUnixTimestamp()', () {
    test('throws when supplied a too large number', () {
      expect(
        () => assertIsUnixTimestamp(BigInt.two.pow(63)),
        throwsA(isA<SolanaError>()),
      );
      expect(
        () => assertIsUnixTimestamp(BigInt.parse('9223372036854775808')),
        throwsA(isA<SolanaError>()),
      );
    });

    test('throws when supplied a too small number', () {
      expect(
        () => assertIsUnixTimestamp(-BigInt.two.pow(63) - BigInt.one),
        throwsA(isA<SolanaError>()),
      );
      expect(
        () => assertIsUnixTimestamp(BigInt.parse('-9223372036854775809')),
        throwsA(isA<SolanaError>()),
      );
    });

    test('does not throw when supplied a zero timestamp', () {
      expect(() => assertIsUnixTimestamp(BigInt.zero), returnsNormally);
    });

    test('does not throw when supplied a valid non-zero timestamp', () {
      expect(
        () => assertIsUnixTimestamp(BigInt.from(1000000000)),
        returnsNormally,
      );
    });

    test('does not throw when supplied the max valid timestamp', () {
      expect(
        () => assertIsUnixTimestamp(BigInt.two.pow(63) - BigInt.one),
        returnsNormally,
      );
      expect(
        () => assertIsUnixTimestamp(BigInt.parse('9223372036854775807')),
        returnsNormally,
      );
    });
  });

  group('isUnixTimestamp()', () {
    test('returns true for valid timestamps', () {
      expect(isUnixTimestamp(BigInt.zero), isTrue);
      expect(isUnixTimestamp(BigInt.from(1000000000)), isTrue);
      expect(isUnixTimestamp(BigInt.two.pow(63) - BigInt.one), isTrue);
      expect(isUnixTimestamp(-BigInt.two.pow(63)), isTrue);
    });

    test('returns false for out-of-range timestamps', () {
      expect(isUnixTimestamp(BigInt.two.pow(63)), isFalse);
      expect(isUnixTimestamp(-BigInt.two.pow(63) - BigInt.one), isFalse);
    });
  });

  group('unixTimestamp()', () {
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
}
