import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:test/test.dart';

class _MockRpcApi extends RpcApi {
  _MockRpcApi(this.handler);

  final Object? Function(String method, List<Object?> params) handler;

  @override
  RpcPlan<Object?>? getPlan(String methodName, List<Object?> params) {
    return RpcPlan<Object?>(
      execute: (config) async => handler(methodName, params),
    );
  }
}

Rpc _mockRpc(
  Object? Function(String method, List<Object?> params) handler,
) {
  return Rpc(
    api: _MockRpcApi(handler),
    transport: (config) async => null,
  );
}

void main() {
  group('createClientWithGetMinimumBalanceFromRpc', () {
    test('computes the minimum balance with the header', () async {
      final rpc = _mockRpc((method, params) {
        expect(method, 'getMinimumBalanceForRentExemption');
        return BigInt.from(1000);
      });
      final client = createClientWithGetMinimumBalanceFromRpc(rpc);
      expect(await client.getMinimumBalance(100), BigInt.from(1000));
    });

    test('computes the minimum balance without the header', () async {
      final rpc = _mockRpc((method, params) {
        expect(params, [BigInt.zero]);
        return BigInt.from(1280); // rate * 128
      });
      final client = createClientWithGetMinimumBalanceFromRpc(rpc);
      expect(
        await client.getMinimumBalance(100, withoutHeader: true),
        BigInt.from(1000),
      );
    });
  });

  group('createClientWithFetchAccountsFromRpc', () {
    test('returns an empty list for no addresses', () async {
      final rpc = _mockRpc((method, params) => null);
      final client = createClientWithFetchAccountsFromRpc(rpc);
      expect(await client.fetchAccounts([]), isEmpty);
    });

    test('fetches a single account', () async {
      final rpc = _mockRpc((method, params) {
        expect(method, 'getAccountInfo');
        return {
          'context': {'slot': BigInt.one},
          'value': null,
        };
      });
      final client = createClientWithFetchAccountsFromRpc(rpc);
      final accounts = await client.fetchAccounts([
        const Address('11111111111111111111111111111111'),
      ]);
      expect(accounts, hasLength(1));
    });
  });

  group('createClientWithInterfacesFromRpc', () {
    test('returns both interfaces', () async {
      final rpc = _mockRpc((method, params) {
        if (method == 'getMinimumBalanceForRentExemption') {
          return BigInt.from(1000);
        }
        return {
          'context': {'slot': BigInt.one},
          'value': null,
        };
      });
      final client = createClientWithInterfacesFromRpc(rpc);
      expect(await client.getMinimumBalance.getMinimumBalance(10), BigInt.from(1000));
      expect(await client.fetchAccounts.fetchAccounts([]), isEmpty);
    });
  });
}
