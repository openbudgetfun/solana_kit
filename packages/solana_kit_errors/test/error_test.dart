import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('SolanaError', () {
    test('creates an error with a code', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(error.code, SolanaErrorCode.blockHeightExceeded);
    });

    test('creates an error with context', () {
      final error = SolanaError(SolanaErrorCode.accountsAccountNotFound, {
        'address': '11111111111111111111111111111111',
      });
      expect(error.code, SolanaErrorCode.accountsAccountNotFound);
      expect(error.context['address'], '11111111111111111111111111111111');
    });

    test('context is unmodifiable', () {
      final error = SolanaError(SolanaErrorCode.accountsAccountNotFound, {
        'address': 'test',
      });
      expect(
        () => (error.context as Map)['new_key'] = 'value',
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('toString includes code and message', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(error.toString(), contains('SolanaError#1'));
      expect(error.toString(), contains('block'));
    });

    test('toString interpolates context variables', () {
      final error = SolanaError(SolanaErrorCode.accountsAccountNotFound, {
        'address': 'MyAddress123',
      });
      expect(error.toString(), contains('MyAddress123'));
    });

    test('implements Exception', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(error, isA<Exception>());
    });

    test('empty context defaults to empty map', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(error.context, isEmpty);
    });
  });

  group('SolanaErrorCode enum', () {
    test('value field returns the numeric code', () {
      expect(SolanaErrorCode.blockHeightExceeded.value, 1);
      expect(SolanaErrorCode.jsonRpcParseError.value, -32700);
      expect(SolanaErrorCode.accountsOneOrMoreAccountsNotFound.value, 32300001);
    });

    test('fromValue returns matching enum for known codes', () {
      expect(SolanaErrorCode.fromValue(1), SolanaErrorCode.blockHeightExceeded);
      expect(SolanaErrorCode.fromValue(-32700), SolanaErrorCode.jsonRpcParseError);
      expect(
        SolanaErrorCode.fromValue(32300001),
        SolanaErrorCode.accountsOneOrMoreAccountsNotFound,
      );
    });

    test('fromValue returns null for unknown codes', () {
      expect(SolanaErrorCode.fromValue(999999), isNull);
      expect(SolanaErrorCode.fromValue(0), isNull);
      expect(SolanaErrorCode.fromValue(-1), isNull);
    });

    test('fromValue round-trips all enum values', () {
      for (final code in SolanaErrorCode.values) {
        expect(SolanaErrorCode.fromValue(code.value), code);
      }
    });

    test('all enum values have distinct numeric values', () {
      final values = SolanaErrorCode.values.map((c) => c.value).toList();
      final unique = values.toSet();
      expect(unique.length, values.length);
    });
  });

  group('isSolanaError', () {
    test('returns true for SolanaError', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(isSolanaError(error), isTrue);
    });

    test('returns true for SolanaError with matching code', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(isSolanaError(error, SolanaErrorCode.blockHeightExceeded), isTrue);
    });

    test('returns false for SolanaError with non-matching code', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(isSolanaError(error, SolanaErrorCode.invalidNonce), isFalse);
    });

    test('returns false for non-SolanaError', () {
      expect(isSolanaError(Exception('test')), isFalse);
    });

    test('returns false for null', () {
      expect(isSolanaError(null), isFalse);
    });

    test('returns false for string', () {
      expect(isSolanaError('not an error'), isFalse);
    });
  });
}
