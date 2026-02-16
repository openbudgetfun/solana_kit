import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('isSolanaErrorWithCode', () {
    test('matches a SolanaError with the correct code', () {
      final error = SolanaError(1);
      expect(error, isSolanaErrorWithCode(1));
    });

    test('does not match a SolanaError with a different code', () {
      final error = SolanaError(1);
      expect(error, isNot(isSolanaErrorWithCode(2)));
    });

    test('does not match non-SolanaError objects', () {
      expect(Exception('oops'), isNot(isSolanaErrorWithCode(1)));
    });
  });

  group('throwsSolanaErrorWithCode', () {
    test('matches when function throws SolanaError with correct code', () {
      expect(() => throw SolanaError(42), throwsSolanaErrorWithCode(42));
    });

    test('does not match when function throws different code', () {
      expect(() => throw SolanaError(42), isNot(throwsSolanaErrorWithCode(99)));
    });
  });

  group('isSolanaErrorWithCodeAndContext', () {
    test('matches when code and context match', () {
      final error = SolanaError(1, {'key': 'value'});
      expect(error, isSolanaErrorWithCodeAndContext(1, {'key': 'value'}));
    });

    test('does not match when context differs', () {
      final error = SolanaError(1, {'key': 'wrong'});
      expect(
        error,
        isNot(isSolanaErrorWithCodeAndContext(1, {'key': 'value'})),
      );
    });
  });

  group('isSolanaErrorMatcher', () {
    test('matches any SolanaError', () {
      expect(SolanaError(1), isSolanaErrorMatcher);
      expect(SolanaError(2, {'a': 'b'}), isSolanaErrorMatcher);
    });

    test('does not match non-SolanaError', () {
      expect(Exception('oops'), isNot(isSolanaErrorMatcher));
      expect('string', isNot(isSolanaErrorMatcher));
    });
  });

  group('throwsSolanaError', () {
    test('matches when function throws any SolanaError', () {
      expect(() => throw SolanaError(99), throwsSolanaError);
    });

    test('does not match when function throws non-SolanaError', () {
      expect(() => throw Exception('oops'), isNot(throwsSolanaError));
    });
  });
}
