import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Shared addresses used across workspace tests.
const testFeePayerAddress = Address(
  'E9Nykp3rSdza2moQutaJ3K3RSC8E5iFERX2SqLTsQfjJ',
);

/// Shared address fixture for account-oriented tests.
const testAccountAddressA = Address(
  'GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G',
);

/// Shared secondary address fixture for multi-account tests.
const testAccountAddressB = Address('11111111111111111111111111111111');

/// Shared program address fixture.
const testProgramAddress = Address(
  'HZMKVnRrWLyQLwPLTTLKtY7ET4Cf7pQugrTr9eTBrpsf',
);

/// Shared owner/program address used by mock account fixtures.
const testOwnerAddress = Address('11111111111111111111111111111111');

/// Shared valid signature string fixture.
const testSignatureValue = Signature(
  '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332SVY7Ru6cME43qT35Z7JKpZqCoPaL',
);

/// Builds 64-byte signature bytes with at least one non-zero entry.
SignatureBytes nonZeroSignatureBytes([int fill = 42]) {
  final normalizedFill = fill == 0 ? 1 : fill;
  return SignatureBytes(
    Uint8List.fromList(List<int>.filled(64, normalizedFill)),
  );
}

/// Creates a minimal transaction fixture for matcher and signer tests.
Transaction createTransactionFixture({
  Address signer = testFeePayerAddress,
  Uint8List? messageBytes,
  SignatureBytes? signature,
}) {
  return Transaction(
    messageBytes: messageBytes ?? Uint8List(32),
    signatures: {signer: signature},
  );
}

/// Builds a mock base64-encoded account payload using Solana RPC response
/// fields.
Map<String, Object?> base64RpcAccountFixture({
  String encodedData = 'somedata',
  bool executable = false,
  int lamports = 1000000000,
  Address owner = testOwnerAddress,
  int space = 6,
}) {
  return <String, Object?>{
    'data': [encodedData, 'base64'],
    'executable': executable,
    'lamports': lamports,
    'owner': owner.value,
    'space': space,
  };
}

/// Builds a mock jsonParsed account payload using Solana RPC response fields.
Map<String, Object?> jsonParsedRpcAccountFixture({
  Map<String, Object?>? info,
  String type = 'token',
  String program = 'splToken',
  bool executable = false,
  int lamports = 1000000000,
  Address owner = testOwnerAddress,
  int space = 165,
}) {
  return <String, Object?>{
    'data': <String, Object?>{
      'parsed': <String, Object?>{
        'info': info ?? <String, Object?>{'mint': '2222', 'owner': '3333'},
        'type': type,
      },
      'program': program,
      'space': space,
    },
    'executable': executable,
    'lamports': lamports,
    'owner': owner.value,
    'space': space,
  };
}

/// Creates a mock [Rpc] that returns account fixtures for account-oriented
/// tests.
Rpc createAccountsFixtureRpc(
  Map<Address, Map<String, Object?>> accounts, {
  BigInt? slot,
}) {
  final effectiveSlot = slot ?? BigInt.zero;
  final accountMap = <String, Map<String, Object?>>{
    for (final entry in accounts.entries) entry.key.value: entry.value,
  };

  final api = MapRpcApi({
    'getAccountInfo': (params) => RpcPlan<Object?>(
      execute: (_) async {
        final address = params[0]! as String;
        return <String, Object?>{
          'context': <String, Object?>{'slot': effectiveSlot},
          'value': accountMap[address],
        };
      },
    ),
    'getMultipleAccounts': (params) => RpcPlan<Object?>(
      execute: (_) async {
        final addresses = (params[0]! as List<Object?>).cast<String>();
        return <String, Object?>{
          'context': <String, Object?>{'slot': effectiveSlot},
          'value': addresses.map((address) => accountMap[address]).toList(),
        };
      },
    ),
  });

  return Rpc(api: api, transport: (_) async => null);
}

/// Captures subscription transport requests while returning a stable publisher.
class CapturingSubscriptionsTransport {
  /// Creates a [CapturingSubscriptionsTransport].
  CapturingSubscriptionsTransport({WritableDataPublisher? publisher})
    : publisher = publisher ?? createDataPublisher();

  /// The publisher returned to subscription callers.
  final WritableDataPublisher publisher;

  /// Every transport config observed by [transport].
  final List<RpcSubscriptionsTransportConfig> configs =
      <RpcSubscriptionsTransportConfig>[];

  /// Transport implementation that records the config and returns [publisher].
  Future<DataPublisher> transport(
    RpcSubscriptionsTransportConfig config,
  ) async {
    configs.add(config);
    return publisher;
  }

  /// The most recent transport config.
  RpcSubscriptionsTransportConfig get lastConfig => configs.last;
}

/// Builds a Helius JSON-RPC subscribe acknowledgement payload.
Map<String, Object?> heliusSubscriptionAckFixture({
  required int id,
  required int subscription,
}) {
  return <String, Object?>{'jsonrpc': '2.0', 'id': id, 'result': subscription};
}

/// Builds a Helius JSON-RPC notification payload.
Map<String, Object?> heliusNotificationFixture({
  required String method,
  required int subscription,
  required Object? result,
}) {
  return <String, Object?>{
    'jsonrpc': '2.0',
    'method': method,
    'params': <String, Object?>{'subscription': subscription, 'result': result},
  };
}
