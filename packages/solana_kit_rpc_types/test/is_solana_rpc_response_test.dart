import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('isSolanaRpcResponse', () {
    test('returns true for a SolanaRpcResponse envelope', () {
      final response = SolanaRpcResponse<Map<String, Object?>>(
        context: RpcResponseContext(slot: BigInt.one),
        value: {'lamports': BigInt.from(42)},
      );
      expect(isSolanaRpcResponse(response), isTrue);
      // The narrowed value is readable without a cast.
      if (isSolanaRpcResponse(response)) {
        expect(response.context.slot, BigInt.one);
        expect(response.value['lamports'], BigInt.from(42));
      }
    });

    test('returns false for a raw value', () {
      expect(isSolanaRpcResponse({'lamports': 42}), isFalse);
      expect(isSolanaRpcResponse(null), isFalse);
      expect(isSolanaRpcResponse(42), isFalse);
    });
  });
}
