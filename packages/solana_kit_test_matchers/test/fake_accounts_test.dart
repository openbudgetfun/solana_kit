import 'dart:typed_data';

import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  test('creates existing encoded account fixtures', () {
    final account = createExistingEncodedAccountFixture(
      address: accountTestAddress,
      data: Uint8List.fromList([1, 2, 3]),
    );

    expect(account.exists, isTrue);
    expect(account.address, accountTestAddress);
    expect(account.data, Uint8List.fromList([1, 2, 3]));
  });

  test('creates missing encoded account fixtures', () {
    final account = createMissingEncodedAccountFixture(accountTestAddress);

    expect(account.exists, isFalse);
    expect(account.address, accountTestAddress);
  });
}
