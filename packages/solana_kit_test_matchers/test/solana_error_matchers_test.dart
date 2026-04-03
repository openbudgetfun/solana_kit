import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('isSolanaErrorWithCode', () {
    test('matches a SolanaError with the correct code', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(error, isSolanaErrorWithCode(SolanaErrorCode.blockHeightExceeded));
    });

    test('does not match a SolanaError with a different code', () {
      final error = SolanaError(SolanaErrorCode.blockHeightExceeded);
      expect(error, isNot(isSolanaErrorWithCode(SolanaErrorCode.invalidNonce)));
    });

    test('does not match non-SolanaError objects', () {
      expect(
        Exception('oops'),
        isNot(isSolanaErrorWithCode(SolanaErrorCode.blockHeightExceeded)),
      );
    });
  });

  group('throwsSolanaErrorWithCode', () {
    test('matches when function throws SolanaError with correct code', () {
      expect(
        () => throw SolanaError(SolanaErrorCode.addressesMaxPdaSeedLengthExceeded),
        throwsSolanaErrorWithCode(
          SolanaErrorCode.addressesMaxPdaSeedLengthExceeded,
        ),
      );
    });

    test('does not match when function throws different code', () {
      expect(
        () => throw SolanaError(SolanaErrorCode.addressesMaxPdaSeedLengthExceeded),
        isNot(throwsSolanaErrorWithCode(SolanaErrorCode.nonceAccountNotFound)),
      );
    });
  });

  group('isSolanaErrorWithCodeAndContext', () {
    test('matches when code and context match', () {
      final error = SolanaError(
        SolanaErrorCode.blockHeightExceeded,
        {'key': 'value'},
      );
      expect(
        error,
        isSolanaErrorWithCodeAndContext(
          SolanaErrorCode.blockHeightExceeded,
          {'key': 'value'},
        ),
      );
    });

    test('does not match when context differs', () {
      final error = SolanaError(
        SolanaErrorCode.blockHeightExceeded,
        {'key': 'wrong'},
      );
      expect(
        error,
        isNot(
          isSolanaErrorWithCodeAndContext(
            SolanaErrorCode.blockHeightExceeded,
            {'key': 'value'},
          ),
        ),
      );
    });
  });

  group('isSolanaErrorMatcher', () {
    test('matches any SolanaError', () {
      expect(SolanaError(SolanaErrorCode.blockHeightExceeded), isSolanaErrorMatcher);
      expect(
        SolanaError(SolanaErrorCode.invalidNonce, {'a': 'b'}),
        isSolanaErrorMatcher,
      );
    });

    test('does not match non-SolanaError', () {
      expect(Exception('oops'), isNot(isSolanaErrorMatcher));
      expect('string', isNot(isSolanaErrorMatcher));
    });
  });

  group('throwsSolanaError', () {
    test('matches when function throws any SolanaError', () {
      expect(
        () => throw SolanaError(SolanaErrorCode.nonceAccountNotFound),
        throwsSolanaError,
      );
    });

    test('does not match when function throws non-SolanaError', () {
      expect(() => throw Exception('oops'), isNot(throwsSolanaError));
    });
  });
}
