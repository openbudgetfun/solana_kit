import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const owner = Address('11111111111111111111111111111111');
  const mint = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

  group('SimulateTransactionAccountsConfig', () {
    test('serializes addresses and optional encoding', () {
      const config = SimulateTransactionAccountsConfig(
        addresses: [owner, mint],
        encoding: AccountEncoding.base64,
      );

      expect(config.toJson(), {
        'addresses': [owner.value, mint.value],
        'encoding': 'base64',
      });
    });

    test('supports equality, hashCode, and toString', () {
      const a = SimulateTransactionAccountsConfig(addresses: [owner, mint]);
      const b = SimulateTransactionAccountsConfig(addresses: [owner, mint]);
      const c = SimulateTransactionAccountsConfig(addresses: [owner]);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains(owner.value));
    });
  });

  group('SimulateTransactionConfig', () {
    test('serializes all populated fields', () {
      final config = SimulateTransactionConfig(
        accounts: const SimulateTransactionAccountsConfig(
          addresses: [owner],
          encoding: AccountEncoding.base64,
        ),
        commitment: Commitment.processed,
        encoding: WireTransactionEncoding.base64,
        innerInstructions: true,
        minContextSlot: BigInt.from(12),
        replaceRecentBlockhash: false,
        sigVerify: true,
      );

      expect(config.toJson(), {
        'accounts': {
          'addresses': [owner.value],
          'encoding': 'base64',
        },
        'commitment': 'processed',
        'encoding': 'base64',
        'innerInstructions': true,
        'minContextSlot': BigInt.from(12),
        'replaceRecentBlockhash': false,
        'sigVerify': true,
      });
    });

    test('supports equality, hashCode, and toString', () {
      const accounts = SimulateTransactionAccountsConfig(addresses: [owner]);
      const a = SimulateTransactionConfig(
        accounts: accounts,
        commitment: Commitment.confirmed,
        innerInstructions: true,
      );
      const b = SimulateTransactionConfig(
        accounts: accounts,
        commitment: Commitment.confirmed,
        innerInstructions: true,
      );
      const c = SimulateTransactionConfig(accounts: accounts);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains('innerInstructions: true'));
    });
  });

  group('simulateTransactionParams', () {
    test('serializes encoded transaction only when config omitted', () {
      expect(simulateTransactionParams('abc123'), ['abc123']);
    });

    test('serializes encoded transaction and config', () {
      final params = simulateTransactionParams(
        'abc123',
        const SimulateTransactionConfig(
          commitment: Commitment.finalized,
          replaceRecentBlockhash: true,
        ),
      );

      expect(params, [
        'abc123',
        {'commitment': 'finalized', 'replaceRecentBlockhash': true},
      ]);
    });
  });
}
