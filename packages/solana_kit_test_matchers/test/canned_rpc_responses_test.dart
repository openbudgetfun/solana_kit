import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('canned RPC responses', () {
    test('getBalanceRpcResult returns context and value', () {
      final result = getBalanceRpcResult();
      expect(result['context'], isA<Map<String, Object?>>());
      expect(result['value'], BigInt.zero);
    });

    test('getBalanceRpcResult accepts custom values', () {
      final result = getBalanceRpcResult(
        slot: BigInt.from(42),
        lamports: BigInt.from(1000),
      );
      final context = result['context']! as Map<String, Object?>;
      expect(context['slot'], BigInt.from(42));
      expect(result['value'], BigInt.from(1000));
    });

    test('getAccountInfoRpcResult returns null value by default', () {
      final result = getAccountInfoRpcResult();
      expect(result['value'], isNull);
    });

    test('getAccountInfoRpcResult accepts custom value', () {
      final result = getAccountInfoRpcResult(
        value: {'data': 'test'},
      );
      expect(result['value'], {'data': 'test'});
    });

    test('getSlotRpcResult returns default slot', () {
      expect(getSlotRpcResult(), BigInt.one);
    });

    test('getSlotRpcResult accepts custom slot', () {
      expect(getSlotRpcResult(slot: BigInt.from(99)), BigInt.from(99));
    });

    test('getLatestBlockhashRpcResult returns default values', () {
      final result = getLatestBlockhashRpcResult();
      final value = result['value']! as Map<String, Object?>;
      expect(value['blockhash'], isA<String>());
      expect(value['lastValidBlockHeight'], BigInt.two);
    });

    test('getSignatureStatusesRpcResult returns default statuses', () {
      final result = getSignatureStatusesRpcResult();
      final value = result['value']! as List<Object?>;
      expect(value, hasLength(1));
      expect(value.first, isNull);
    });

    test('sendTransactionRpcResult returns default signature', () {
      expect(sendTransactionRpcResult(), isA<String>());
      expect(sendTransactionRpcResult().length, greaterThan(10));
    });

    test('requestAirdropRpcResult returns default signature', () {
      expect(requestAirdropRpcResult(), isA<String>());
    });

    test('getEpochInfoRpcResult returns all fields', () {
      final result = getEpochInfoRpcResult();
      expect(result['absoluteSlot'], isNotNull);
      expect(result['blockHeight'], isNotNull);
      expect(result['epoch'], isNotNull);
      expect(result['slotIndex'], isNotNull);
      expect(result['slotsInEpoch'], isNotNull);
      expect(result['transactionCount'], isNotNull);
    });

    test('getTransactionRpcResult returns structured result', () {
      final result = getTransactionRpcResult();
      expect(result['slot'], isNotNull);
      expect(result['transaction'], isA<Map<String, Object?>>());
      expect(result['version'], 'legacy');
    });
  });
}
