import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('equalsBytes', () {
    test('describes mismatch for non-Uint8List values', () {
      final matcher = equalsBytes(Uint8List.fromList([1, 2, 3]));
      final description = StringDescription();

      matcher.describeMismatch('oops', description, <Object?, Object?>{}, false);

      expect(description.toString(), 'is not a Uint8List');
    });

    test('describes mismatch for length differences', () {
      final matcher = equalsBytes(Uint8List.fromList([1, 2, 3]));
      final description = StringDescription();

      matcher.describeMismatch(
        Uint8List.fromList([1, 2]),
        description,
        <Object?, Object?>{},
        false,
      );

      expect(description.toString(), 'has length 2, expected 3');
    });

    test('describes mismatch for differing byte values', () {
      final matcher = equalsBytes(Uint8List.fromList([1, 2, 3]));
      final description = StringDescription();

      matcher.describeMismatch(
        Uint8List.fromList([1, 9, 3]),
        description,
        <Object?, Object?>{},
        false,
      );

      expect(description.toString(), contains('differs at index 1'));
      expect(description.toString(), contains('got 0x09'));
      expect(description.toString(), contains('expected 0x02'));
    });

    test('describe truncates long byte arrays', () {
      final matcher = equalsBytes(Uint8List.fromList(List<int>.generate(10, (i) => i)));
      final description = StringDescription();

      matcher.describe(description);

      expect(description.toString(), contains('...(10 bytes)'));
    });
  });

  group('startsWithBytes', () {
    test('describes mismatch for non-Uint8List values', () {
      final matcher = startsWithBytes(Uint8List.fromList([1, 2]));
      final description = StringDescription();

      matcher.describeMismatch(1, description, <Object?, Object?>{}, false);

      expect(description.toString(), 'is not a Uint8List');
    });

    test('describes mismatch for shorter-than-prefix values', () {
      final matcher = startsWithBytes(Uint8List.fromList([1, 2, 3]));
      final description = StringDescription();

      matcher.describeMismatch(
        Uint8List.fromList([1, 2]),
        description,
        <Object?, Object?>{},
        false,
      );

      expect(
        description.toString(),
        'has length 2, which is shorter than prefix length 3',
      );
    });
  });

  group('isValidSolanaAddress', () {
    test('describeMismatch explains invalid Address input', () {
      final description = StringDescription();
      const invalid = Address('invalid-base58');

      isValidSolanaAddress.describeMismatch(
        invalid,
        description,
        <Object?, Object?>{},
        false,
      );

      expect(description.toString(), 'is not a valid base58-encoded address');
    });
  });

  group('isFullySignedTransactionMatcher', () {
    test('describeMismatch explains non-transaction input', () {
      final description = StringDescription();

      isFullySignedTransactionMatcher.describeMismatch(
        'oops',
        description,
        <Object?, Object?>{},
        false,
      );

      expect(description.toString(), 'is not a Transaction');
    });

    test('describeMismatch explains missing signatures', () {
      final description = StringDescription();
      final transaction = Transaction(
        messageBytes: Uint8List(1),
        signatures: const {},
      );

      isFullySignedTransactionMatcher.describeMismatch(
        transaction,
        description,
        <Object?, Object?>{},
        false,
      );

      expect(description.toString(), 'has no signatures');
    });

    test('describeMismatch explains unsigned entries', () {
      const feePayer = Address('11111111111111111111111111111111');
      final description = StringDescription();
      final transaction = Transaction(
        messageBytes: Uint8List(1),
        signatures: {
          feePayer: SignatureBytes(Uint8List(64)),
        },
      );

      isFullySignedTransactionMatcher.describeMismatch(
        transaction,
        description,
        <Object?, Object?>{},
        false,
      );

      expect(description.toString(), contains('has unsigned entries for:'));
      expect(description.toString(), contains(feePayer.toString()));
    });
  });
}
