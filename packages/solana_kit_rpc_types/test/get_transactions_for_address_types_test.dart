import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetTransactionsForAddressApiResponse', () {
    test('holds data and pagination token', () {
      const response = GetTransactionsForAddressApiResponse<int>(
        data: [1, 2],
        paginationToken: '1:2',
      );
      expect(response.data, [1, 2]);
      expect(response.paginationToken, '1:2');
    });
  });

  group('GetTransactionsForAddressSignature', () {
    test('holds signature fields', () {
      final entry = GetTransactionsForAddressSignature(
        blockTime: 123,
        confirmationStatus: Commitment.confirmed,
        err: null,
        memo: 'memo',
        signature: 'sig',
        slot: BigInt.from(5),
        transactionIndex: 2,
      );
      expect(entry.blockTime, 123);
      expect(entry.confirmationStatus, Commitment.confirmed);
      expect(entry.memo, 'memo');
      expect(entry.signature, 'sig');
      expect(entry.slot, BigInt.from(5));
      expect(entry.transactionIndex, 2);
    });
  });

  group('GetTransactionsForAddressFullBase', () {
    test('holds base fields', () {
      final entry = GetTransactionsForAddressFullBase(
        blockTime: null,
        slot: BigInt.from(9),
        transactionIndex: 0,
      );
      expect(entry.blockTime, isNull);
      expect(entry.slot, BigInt.from(9));
      expect(entry.transactionIndex, 0);
    });
  });
}
