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

  group('SimulateTransactionLoadedAddresses', () {
    test('supports equality, hashCode, and toString', () {
      const a = SimulateTransactionLoadedAddresses(
        readonly: [owner],
        writable: [mint],
      );
      const b = SimulateTransactionLoadedAddresses(
        readonly: [owner],
        writable: [mint],
      );
      const c = SimulateTransactionLoadedAddresses(
        readonly: [mint],
        writable: [owner],
      );
      const d = SimulateTransactionLoadedAddresses(
        readonly: [owner],
        writable: [],
      );

      expect(a, a);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
      expect(a.toString(), contains('readonly'));
    });
  });

  group('SimulateTransactionResult', () {
    test('supports equality, hashCode, and toString for populated values', () {
      const loadedAddresses = SimulateTransactionLoadedAddresses(
        readonly: [owner],
        writable: [mint],
      );
      final a = SimulateTransactionResult(
        err: null,
        fee: lamports(BigInt.from(5000)),
        loadedAccountsDataSize: 128,
        loadedAddresses: loadedAddresses,
        logs: const ['Program log: ok'],
        postBalances: [lamports(BigInt.from(10))],
        postTokenBalances: const [],
        preBalances: [lamports(BigInt.from(20))],
        preTokenBalances: const [],
        returnData: const ReturnData(
          data: (Base64EncodedBytes('AQID'), 'base64'),
          programId: owner,
        ),
        unitsConsumed: BigInt.from(42),
      );
      final b = SimulateTransactionResult(
        err: null,
        fee: lamports(BigInt.from(5000)),
        loadedAccountsDataSize: 128,
        loadedAddresses: loadedAddresses,
        logs: const ['Program log: ok'],
        postBalances: [lamports(BigInt.from(10))],
        postTokenBalances: const [],
        preBalances: [lamports(BigInt.from(20))],
        preTokenBalances: const [],
        returnData: const ReturnData(
          data: (Base64EncodedBytes('AQID'), 'base64'),
          programId: owner,
        ),
        unitsConsumed: BigInt.from(42),
      );
      // Keep this non-const so equality reaches nullable list comparison.
      // ignore: prefer_const_declarations
      final List<String>? noLogs = null;
      final c = SimulateTransactionResult(
        err: null,
        fee: null,
        loadedAddresses: null,
        logs: noLogs,
        postBalances: null,
        postTokenBalances: null,
        preBalances: null,
        preTokenBalances: null,
        returnData: null,
      );
      final d = SimulateTransactionResult(
        err: null,
        fee: null,
        loadedAddresses: null,
        logs: noLogs,
        postBalances: null,
        postTokenBalances: null,
        preBalances: null,
        preTokenBalances: null,
        returnData: null,
      );

      expect(a, a);
      expect(c, c);
      expect(c, d);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a.toString(), contains('unitsConsumed: 42'));
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
