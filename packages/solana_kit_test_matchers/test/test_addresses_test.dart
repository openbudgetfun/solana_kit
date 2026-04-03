import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('test addresses', () {
    test('systemProgramTestAddress is the system program', () {
      expect(
        systemProgramTestAddress,
        const Address('11111111111111111111111111111111'),
      );
    });

    test('tokenProgramTestAddress is the SPL token program', () {
      expect(
        tokenProgramTestAddress,
        const Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA'),
      );
    });

    test('signerTestAddress is a valid address', () {
      expect(signerTestAddress.value, isNotEmpty);
    });

    test('accountTestAddress is a valid address', () {
      expect(accountTestAddress.value, isNotEmpty);
    });

    test('all test addresses are distinct', () {
      final addresses = {
        systemProgramTestAddress,
        tokenProgramTestAddress,
        signerTestAddress,
        accountTestAddress,
      };
      expect(addresses, hasLength(4));
    });
  });
}
