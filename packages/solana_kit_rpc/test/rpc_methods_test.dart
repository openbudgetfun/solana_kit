import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('SolanaRpcMethods', () {
    const testAddress = Address('11111111111111111111111111111111');
    const testSignature = Signature('test-signature');

    test('getAccountInfo sends method-specific params', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .getAccountInfo(
              testAddress,
              const GetAccountInfoConfig(encoding: 'base64'),
            )
            .send(),
        rpcResult: {
          'context': {'slot': 1},
          'value': null,
        },
      );

      expect(response.payload['method'], 'getAccountInfo');
      expect(response.payload['params'], [
        testAddress.value,
        {'encoding': 'base64', 'commitment': 'confirmed'},
      ]);
      expect(response.result, isA<Map<String, Object?>>());
    });

    test('getBalance sends method-specific params', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .getBalance(
              testAddress,
              const GetBalanceConfig(commitment: Commitment.confirmed),
            )
            .send(),
        rpcResult: {
          'context': {'slot': 1},
          'value': 1000,
        },
      );

      expect(response.payload['method'], 'getBalance');
      expect(response.payload['params'], [
        testAddress.value,
        {'commitment': 'confirmed'},
      ]);
      expect(response.result, isA<Map<String, Object?>>());
    });

    test('getBlockHeight returns a typed slot', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .getBlockHeight(
              const GetBlockHeightConfig(commitment: Commitment.finalized),
            )
            .send(),
        rpcResult: 42,
      );

      expect(response.payload['method'], 'getBlockHeight');
      // `finalized` is server default and is stripped by request transformers.
      expect(response.payload['params'], <Object?>[]);
      expect(response.result, BigInt.from(42));
    });

    test('getEpochInfo sends method-specific params', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .getEpochInfo(
              const GetEpochInfoConfig(commitment: Commitment.confirmed),
            )
            .send(),
        rpcResult: {
          'absoluteSlot': 42,
          'blockHeight': 41,
          'epoch': 2,
          'slotIndex': 1,
          'slotsInEpoch': 432000,
          'transactionCount': 99,
        },
      );

      expect(response.payload['method'], 'getEpochInfo');
      expect(response.payload['params'], [
        {'commitment': 'confirmed'},
      ]);
      expect(response.result, isA<Map<String, Object?>>());
    });

    test('getFeeForMessage sends method-specific params', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .getFeeForMessage(
              'base64-message',
              const GetFeeForMessageConfig(commitment: Commitment.processed),
            )
            .send(),
        rpcResult: {
          'context': {'slot': 1},
          'value': 5000,
        },
      );

      expect(response.payload['method'], 'getFeeForMessage');
      expect(response.payload['params'], [
        'base64-message',
        {'commitment': 'processed'},
      ]);
      expect(response.result, isA<Map<String, Object?>>());
    });

    test('getLatestBlockhash sends method-specific params', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .getLatestBlockhash(
              const GetLatestBlockhashConfig(commitment: Commitment.confirmed),
            )
            .send(),
        rpcResult: {
          'context': {'slot': 1},
          'value': {
            'blockhash': 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
            'lastValidBlockHeight': 10,
          },
        },
      );

      expect(response.payload['method'], 'getLatestBlockhash');
      expect(response.payload['params'], [
        {'commitment': 'confirmed'},
      ]);
      expect(response.result, isA<Map<String, Object?>>());
    });

    test('getSignatureStatuses sends method-specific params', () async {
      final response = await _captureCall(
        (rpc) => rpc.getSignatureStatuses(
          [testSignature],
          const GetSignatureStatusesConfig(searchTransactionHistory: true),
        ).send(),
        rpcResult: {
          'context': {'slot': 1},
          'value': [null],
        },
      );

      expect(response.payload['method'], 'getSignatureStatuses');
      expect(response.payload['params'], [
        [testSignature.value],
        {'searchTransactionHistory': true},
      ]);
      expect(response.result, isA<Map<String, Object?>>());
    });

    test('getSlot returns a typed slot', () async {
      final response = await _captureCall(
        (rpc) => rpc.getSlot(const GetSlotConfig()).send(),
        rpcResult: 99,
      );

      expect(response.payload['method'], 'getSlot');
      expect(response.payload['params'], [
        {'commitment': 'confirmed'},
      ]);
      expect(response.result, BigInt.from(99));
    });

    test('getTransaction returns null when result is missing', () async {
      final response = await _captureCall<Map<String, Object?>?>(
        (rpc) => rpc.getTransaction(testSignature).send(),
        rpcResult: null,
      );

      expect(response.payload['method'], 'getTransaction');
      expect(response.payload['params'], [
        testSignature.value,
        {'commitment': 'confirmed'},
      ]);
      expect(response.result, isNull);
    });

    test('requestAirdrop returns transaction signature', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .requestAirdrop(
              testAddress,
              Lamports(BigInt.from(5000)),
              const RequestAirdropConfig(commitment: Commitment.confirmed),
            )
            .send(),
        rpcResult: 'airdrop-signature',
      );

      expect(response.payload['method'], 'requestAirdrop');
      final params = response.payload['params']! as List<Object?>;
      expect(params.first, testAddress.value);
      expect(params[1], anyOf(BigInt.from(5000), 5000));
      expect(params[2], {'commitment': 'confirmed'});
      expect(response.result, 'airdrop-signature');
    });

    test('sendTransaction returns transaction signature', () async {
      final response = await _captureCall(
        (rpc) => rpc
            .sendTransaction(
              'AQIDBA==',
              const SendTransactionConfig(skipPreflight: true),
            )
            .send(),
        rpcResult: 'send-signature',
      );

      expect(response.payload['method'], 'sendTransaction');
      expect(response.payload['params'], [
        'AQIDBA==',
        {'skipPreflight': true, 'preflightCommitment': 'confirmed'},
      ]);
      expect(response.result, 'send-signature');
    });
  });
}

Future<({T result, Map<String, Object?> payload})> _captureCall<
  T extends Object?
>(Future<T> Function(Rpc rpc) invoke, {required Object? rpcResult}) async {
  late Map<String, Object?> payload;

  final rpc = createSolanaRpcFromTransport((config) async {
    payload = Map<String, Object?>.from(
      config.payload! as Map<String, Object?>,
    );
    return {'jsonrpc': '2.0', 'id': '1', 'result': rpcResult};
  });

  final result = await invoke(rpc);
  return (result: result, payload: payload);
}
