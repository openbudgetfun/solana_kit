import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Helper: extract the mismatch description string from a matcher.
// ---------------------------------------------------------------------------
String _mismatch(Matcher matcher, Object? item) {
  final matchState = <dynamic, dynamic>{};
  matcher.matches(item, matchState);
  final desc = StringDescription();
  matcher.describeMismatch(item, desc, matchState, false);
  return desc.toString();
}

String _describe(Matcher matcher) {
  final desc = StringDescription();
  matcher.describe(desc);
  return desc.toString();
}

// ---------------------------------------------------------------------------
// equalsBytes – describe / describeMismatch
// ---------------------------------------------------------------------------
void main() {
  const feePayer = Address('E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ');

  group('equalsBytes describe', () {
    test('describe mentions expected bytes for short arrays', () {
      final matcher = equalsBytes(Uint8List.fromList([0x01, 0x02]));
      final desc = _describe(matcher);
      expect(desc, contains('0x01'));
      expect(desc, contains('0x02'));
    });

    test('describe uses truncated format for arrays longer than 8 bytes', () {
      final expected = Uint8List.fromList(
        List.generate(12, (i) => i + 1),
      );
      final matcher = equalsBytes(expected);
      final desc = _describe(matcher);
      // Should contain "..." to indicate truncation.
      expect(desc, contains('...'));
      expect(desc, contains('12 bytes'));
    });
  });

  group('equalsBytes describeMismatch', () {
    test('reports "is not a Uint8List" for non-Uint8List input', () {
      final matcher = equalsBytes(Uint8List.fromList([1, 2, 3]));
      final msg = _mismatch(matcher, 'hello');
      expect(msg, contains('not a Uint8List'));
    });

    test('reports length difference when lengths differ', () {
      final matcher = equalsBytes(Uint8List.fromList([1, 2, 3]));
      final msg = _mismatch(matcher, Uint8List.fromList([1, 2]));
      expect(msg, contains('length'));
      expect(msg, contains('2'));
      expect(msg, contains('3'));
    });

    test('reports first differing byte index', () {
      final matcher = equalsBytes(Uint8List.fromList([1, 2, 3]));
      final msg = _mismatch(matcher, Uint8List.fromList([1, 9, 3]));
      expect(msg, contains('index 1'));
    });

    test('matches empty vs empty with no mismatch', () {
      final matcher = equalsBytes(Uint8List(0));
      final matchState = <dynamic, dynamic>{};
      expect(matcher.matches(Uint8List(0), matchState), isTrue);
    });

    test('mismatch for identical byte arrays returns empty description', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final matcher = equalsBytes(bytes);
      final matchState = <dynamic, dynamic>{};
      matcher.matches(bytes, matchState);
      final desc = StringDescription();
      matcher.describeMismatch(bytes, desc, matchState, false);
      // When matched, describeMismatch returns the same description unchanged.
      expect(desc.toString(), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // hasByteLength
  // ---------------------------------------------------------------------------
  group('hasByteLength', () {
    test('describe mentions the expected length', () {
      final matcher = hasByteLength(64);
      final desc = _describe(matcher);
      expect(desc, contains('64'));
    });

  });

  // ---------------------------------------------------------------------------
  // startsWithBytes – describe / describeMismatch
  // ---------------------------------------------------------------------------
  group('startsWithBytes describe', () {
    test('describe mentions the prefix bytes', () {
      final matcher = startsWithBytes(Uint8List.fromList([0xAB, 0xCD]));
      final desc = _describe(matcher);
      expect(desc, contains('starts with bytes'));
    });
  });

  group('startsWithBytes describeMismatch', () {
    test('reports "is not a Uint8List" for non-Uint8List input', () {
      final matcher = startsWithBytes(Uint8List.fromList([1, 2]));
      final msg = _mismatch(matcher, 42);
      expect(msg, contains('not a Uint8List'));
    });

    test('reports that the array is shorter than the prefix', () {
      final matcher = startsWithBytes(Uint8List.fromList([1, 2, 3, 4, 5]));
      final msg = _mismatch(matcher, Uint8List.fromList([1, 2]));
      expect(msg, contains('shorter'));
    });

  });

  // ---------------------------------------------------------------------------
  // isFullySignedTransactionMatcher – describe / describeMismatch
  // ---------------------------------------------------------------------------
  group('isFullySignedTransactionMatcher describe', () {
    test('describe mentions fully signed transaction', () {
      final desc = _describe(isFullySignedTransactionMatcher);
      expect(desc, contains('fully signed'));
    });
  });

  group('isFullySignedTransactionMatcher describeMismatch', () {
    test('reports "is not a Transaction" for non-transaction input', () {
      final msg = _mismatch(isFullySignedTransactionMatcher, 'not-a-tx');
      expect(msg, contains('not a Transaction'));
    });

    test('reports "has no signatures" for empty signatures map', () {
      final tx = Transaction(
        messageBytes: Uint8List(32),
        signatures: const {},
      );
      final msg = _mismatch(isFullySignedTransactionMatcher, tx);
      expect(msg, contains('no signatures'));
    });

    test('reports unsigned entries for all-zero signatures', () {
      final tx = Transaction(
        messageBytes: Uint8List(32),
        signatures: {feePayer: SignatureBytes(Uint8List(64))},
      );
      final msg = _mismatch(isFullySignedTransactionMatcher, tx);
      expect(msg, contains('unsigned'));
    });

    test('reports null signature entries', () {
      final tx = Transaction(
        messageBytes: Uint8List(32),
        signatures: {feePayer: null},
      );
      final msg = _mismatch(isFullySignedTransactionMatcher, tx);
      expect(msg, contains('unsigned'));
    });
  });

  group('hasSignatureCount describe', () {
    test('describe mentions the expected count', () {
      final desc = _describe(hasSignatureCount(2));
      expect(desc, contains('2'));
    });
  });

  // ---------------------------------------------------------------------------
  // isValidSolanaAddress – describe / describeMismatch
  // ---------------------------------------------------------------------------
  group('isValidSolanaAddress describe', () {
    test('describe mentions valid Solana address', () {
      final desc = _describe(isValidSolanaAddress);
      expect(desc, contains('valid Solana address'));
    });
  });

  group('isValidSolanaAddress describeMismatch', () {
    test('reports "is not an Address" for non-String input', () {
      // Address is an extension type over String; at runtime integers are NOT
      // Strings so they trigger the 'is not an Address' branch.
      final msg = _mismatch(isValidSolanaAddress, 42);
      expect(msg, contains('not an Address'));
    });

    test('reports base58 error for an Address wrapping an invalid value', () {
      // A String wraps into Address extension type at runtime, so if it's
      // invalid base58 it reaches the second branch.
      final msg = _mismatch(isValidSolanaAddress, 'bad!address');
      expect(msg, contains('not a valid base58-encoded address'));
    });

  });

  // ---------------------------------------------------------------------------
  // equalsAddress – describe / describeMismatch
  // ---------------------------------------------------------------------------
  group('equalsAddress describe', () {
    test('describe mentions the expected address', () {
      const expected = Address('11111111111111111111111111111111');
      final desc = _describe(equalsAddress(expected));
      expect(desc, contains('11111111111111111111111111111111'));
    });
  });

}
