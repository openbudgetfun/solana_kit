import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_test_matchers/solana_kit_test_matchers.dart';
import 'package:test/test.dart';

void main() {
  group('FakeRpcTransport', () {
    test('returns canned responses and records calls', () async {
      final fake = FakeRpcTransport({
        'getSlot': BigInt.from(42),
      });

      final response = (await fake.call(
        const RpcTransportConfig(
          payload: {
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'getSlot',
            'params': <Object?>[],
          },
        ),
      ))! as Map<String, Object?>;

      expect(fake.calls, hasLength(1));
      expect(response['result'], BigInt.from(42));
    });

    test('supports per-method response factories', () async {
      final fake = FakeRpcTransport({
        'echo': (List<Object?> params) => {'params': params},
      });

      final response = (await fake.call(
        const RpcTransportConfig(
          payload: {
            'jsonrpc': '2.0',
            'id': 2,
            'method': 'echo',
            'params': <Object?>['hello'],
          },
        ),
      ))! as Map<String, Object?>;

      expect(response['result'], {'params': ['hello']});
    });
  });

  group('createFakeRpc', () {
    test('builds a typed RPC client backed by the fake transport', () async {
      final fake = createFakeRpc({
        'getSlot': BigInt.from(7),
      });

      final slot = await fake.rpc.getSlot().send();

      expect(slot, BigInt.from(7));
      expect(fake.transport.calls, hasLength(1));
    });
  });
}
