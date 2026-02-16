import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('isValidSolanaAddress', () {
    test('matches a valid Solana address', () {
      const address = Address('11111111111111111111111111111111');
      expect(address, isValidSolanaAddress);
    });

    test('does not match non-Address objects', () {
      expect('not an address', isNot(isValidSolanaAddress));
      expect(123, isNot(isValidSolanaAddress));
    });
  });

  group('equalsAddress', () {
    test('matches equal addresses', () {
      const a = Address('11111111111111111111111111111111');
      const b = Address('11111111111111111111111111111111');
      expect(a, equalsAddress(b));
    });

    test('does not match different addresses', () {
      const a = Address('11111111111111111111111111111111');
      const b = Address('E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ');
      expect(a, isNot(equalsAddress(b)));
    });
  });
}
