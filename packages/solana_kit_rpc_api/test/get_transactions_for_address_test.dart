import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('getTransactionsForAddressParams', () {
    test('builds params with just the address', () {
      final params = getTransactionsForAddressParams(
        const Address('11111111111111111111111111111111'),
      );
      expect(params, ['11111111111111111111111111111111']);
    });

    test('builds params with a full config', () {
      final params = getTransactionsForAddressParams(
        const Address('11111111111111111111111111111111'),
        const GetTransactionsForAddressConfig(
          limit: 10,
          sortOrder: 'asc',
          transactionDetails: 'full',
          encoding: TransactionEncoding.base64,
          maxSupportedTransactionVersion: 0,
        ),
      );
      expect(params[0], '11111111111111111111111111111111');
      final config = params[1]! as Map<String, Object?>;
      expect(config['limit'], 10);
      expect(config['sortOrder'], 'asc');
      expect(config['transactionDetails'], 'full');
      expect(config['encoding'], 'base64');
      expect(config['maxSupportedTransactionVersion'], 0);
    });

    test('builds params with filters', () {
      final params = getTransactionsForAddressParams(
        const Address('11111111111111111111111111111111'),
        GetTransactionsForAddressConfig(
          filters: GetTransactionsForAddressFilters(
            status: 'succeeded',
            tokenAccounts: 'balanceChanged',
            slot: GetTransactionsForAddressComparison(
              gte: BigInt.from(100),
            ),
          ),
        ),
      );
      final config = params[1]! as Map<String, Object?>;
      final filters = config['filters']! as Map<String, Object?>;
      expect(filters['status'], 'succeeded');
      expect(filters['tokenAccounts'], 'balanceChanged');
      final slot = filters['slot']! as Map<String, Object?>;
      expect(slot['gte'], BigInt.from(100));
    });
  });
}
