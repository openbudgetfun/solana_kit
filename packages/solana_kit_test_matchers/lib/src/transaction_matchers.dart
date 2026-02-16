import 'dart:typed_data';

import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

/// A matcher that verifies a [Transaction] has all required signatures
/// populated (non-null and non-zero).
///
/// ```dart
/// expect(transaction, isFullySignedTransactionMatcher);
/// ```
const Matcher isFullySignedTransactionMatcher =
    _IsFullySignedTransactionMatcher();

class _IsFullySignedTransactionMatcher extends Matcher {
  const _IsFullySignedTransactionMatcher();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is! Transaction) return false;
    return item.signatures.isNotEmpty &&
        item.signatures.values.every(
          (SignatureBytes? sig) =>
              sig != null && (sig as Uint8List).any((int byte) => byte != 0),
        );
  }

  @override
  Description describe(Description description) =>
      description.add('is a fully signed transaction');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is! Transaction) {
      return mismatchDescription.add('is not a Transaction');
    }
    if (item.signatures.isEmpty) {
      return mismatchDescription.add('has no signatures');
    }
    final zeroSigs = item.signatures.entries
        .where(
          (e) =>
              e.value == null ||
              (e.value! as Uint8List).every((int byte) => byte == 0),
        )
        .map((e) => e.key.toString())
        .toList();
    if (zeroSigs.isNotEmpty) {
      return mismatchDescription.add(
        'has unsigned entries for: ${zeroSigs.join(', ')}',
      );
    }
    return mismatchDescription;
  }
}

/// Returns a matcher that verifies a [Transaction] has exactly [count]
/// signatures.
///
/// ```dart
/// expect(transaction, hasSignatureCount(2));
/// ```
Matcher hasSignatureCount(int count) => isA<Transaction>().having(
  (t) => t.signatures.length,
  'signature count',
  count,
);
