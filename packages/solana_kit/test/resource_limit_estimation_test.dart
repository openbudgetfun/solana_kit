import 'dart:async';
import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

/// Tests for the simulate-based resource-limit estimator.
///
/// The estimator is the only supported way to obtain the compute unit and
/// loaded accounts data size limits that version 1 transactions must state
/// explicitly, so these tests drive a fake transport to pin its behavior
/// without a network round trip.
void main() {
  const mockBlockhash = '11111111111111111111111111111111';

  /// Records every JSON-RPC request the estimator issues and replies with
  /// [result] (or [error]).
  ({Rpc rpc, List<Map<String, Object?>> requests}) fakeRpc({
    required Object? result,
    Object? error,
  }) {
    final requests = <Map<String, Object?>>[];
    final rpc = createSolanaRpcFromTransport((config) async {
      final payload = config.payload! as Map<String, Object?>;
      requests.add(payload);

      return <String, Object?>{
        'jsonrpc': '2.0',
        'id': payload['id'],
        if (error != null) 'error': error else 'result': result,
      };
    });

    return (rpc: rpc, requests: requests);
  }

  /// A v1 message with a fee payer and one instruction.
  TransactionMessage v1Message() {
    return TransactionMessageWithFeePayerSigner(
      feePayerSigner: generateKeyPairSigner(),
      version: TransactionVersion.v1,
      instructions: [
        Instruction(
          programAddress: const Address('11111111111111111111111111111111'),
          accounts: const [],
          data: Uint8List(0),
        ),
      ],
      lifetimeConstraint: BlockhashLifetimeConstraint(
        blockhash: mockBlockhash,
        lastValidBlockHeight: BigInt.from(1000),
      ),
    );
  }

  /// A legacy message with a fee payer and one instruction.
  TransactionMessage legacyMessage() {
    return TransactionMessageWithFeePayerSigner(
      feePayerSigner: generateKeyPairSigner(),
      version: TransactionVersion.legacy,
      instructions: [
        Instruction(
          programAddress: const Address('11111111111111111111111111111111'),
          accounts: const [],
          data: Uint8List(0),
        ),
      ],
      lifetimeConstraint: BlockhashLifetimeConstraint(
        blockhash: mockBlockhash,
        lastValidBlockHeight: BigInt.from(1000),
      ),
    );
  }

  /// Builds a successful simulateTransaction result.
  Map<String, Object?> simulationResult({
    Object? unitsConsumed = 5000,
    Object? loadedAccountsDataSize = 2048,
    Object? err,
  }) {
    return {
      'context': {'slot': 1},
      'value': {
        'err': err,
        'logs': <String>[],
        'unitsConsumed': unitsConsumed,
        'loadedAccountsDataSize': loadedAccountsDataSize,
        'returnData': null,
        'preBalances': <Object?>[],
        'postBalances': <Object?>[],
        'preTokenBalances': <Object?>[],
        'postTokenBalances': <Object?>[],
      },
    };
  }

  group('estimateResourceLimitsFactory', () {
    test('returns the compute units the node reported', () async {
      final fake = fakeRpc(result: simulationResult(unitsConsumed: 12345));
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      final limits = await estimate(v1Message());

      expect(limits.computeUnitLimit, equals(12345));
    });

    test('returns the loaded accounts data size for a v1 message', () async {
      final fake = fakeRpc(
        result: simulationResult(loadedAccountsDataSize: 4096),
      );
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      final limits = await estimate(v1Message());

      expect(limits.loadedAccountsDataSizeLimit, equals(4096));
    });

    test('simulates with both limits maxed', () async {
      final fake = fakeRpc(result: simulationResult());
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      await estimate(v1Message());

      // Decode the wire transaction that was sent and confirm the message
      // config carries the simulation ceilings rather than the caller's values.
      final request = fake.requests.single;
      expect(request['method'], equals('simulateTransaction'));
      final params = request['params']! as List<Object?>;
      final wireBytes = getBase64Encoder().encode(params.first! as String);
      final decoded = getTransactionDecoder().read(wireBytes, 0).$1;
      final compiled = getCompiledTransactionMessageDecoder()
          .read(
            decoded.messageBytes,
            0,
          )
          .$1;

      expect(compiled.configMask, isNot(equals(0)));
      final config = decompileTransactionMessage(compiled).config;
      expect(config?.computeUnitLimit, equals(maxComputeUnitLimit));
      expect(
        config?.loadedAccountsDataSizeLimit,
        equals(maxLoadedAccountsDataSizeLimit),
      );
    });

    test(
      'disables signature verification and replaces the blockhash',
      () async {
        final fake = fakeRpc(result: simulationResult());
        final estimate = estimateResourceLimitsFactory(
          EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
        );

        await estimate(v1Message());

        final params = fake.requests.single['params']! as List<Object?>;
        final config = params[1]! as Map<String, Object?>;
        expect(config['encoding'], equals('base64'));
        expect(config['sigVerify'], isFalse);
        expect(config['replaceRecentBlockhash'], isTrue);
      },
    );

    test(
      'leaves the loaded accounts limit unset for a legacy message',
      () async {
        final fake = fakeRpc(result: simulationResult());
        final estimate = estimateResourceLimitsFactory(
          EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
        );

        await estimate(legacyMessage());

        final params = fake.requests.single['params']! as List<Object?>;
        final wireBytes = getBase64Encoder().encode(params.first! as String);
        final decoded = getTransactionDecoder().read(wireBytes, 0).$1;
        final compiled = getCompiledTransactionMessageDecoder()
            .read(
              decoded.messageBytes,
              0,
            )
            .$1;

        // A legacy compiled message has no config region at all: version 1 is
        // the only version that carries an inline config, so nothing was
        // written for the loaded accounts limit.
        expect(compiled.configMask, isNull);
        expect(compiled.configValues, isNull);
      },
    );

    test('caps a u64 overflow at the u32 ceiling', () async {
      final fake = fakeRpc(
        result: simulationResult(unitsConsumed: BigInt.from(99999999999)),
      );
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      final limits = await estimate(v1Message());

      expect(limits.computeUnitLimit, equals(4294967295));
    });

    test('throws when the node omits the compute units', () async {
      final fake = fakeRpc(result: simulationResult(unitsConsumed: null));
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      await expectLater(
        estimate(v1Message()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionFailedToEstimateComputeLimit,
          ),
        ),
      );
    });

    test(
      'throws when a v1 simulation omits the loaded accounts size',
      () async {
        final fake = fakeRpc(
          result: simulationResult(loadedAccountsDataSize: null),
        );
        final estimate = estimateResourceLimitsFactory(
          EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
        );

        await expectLater(
          estimate(v1Message()),
          throwsA(
            isA<SolanaError>().having(
              (e) => e.code,
              'code',
              SolanaErrorCode
                  .transactionFailedToEstimateLoadedAccountsDataSizeLimit,
            ),
          ),
        );
      },
    );

    test('reports a transaction failure with the decoded cause', () async {
      final fake = fakeRpc(
        result: simulationResult(
          err: {
            'InsufficientFundsForRent': {'account_index': 1},
          },
        ),
      );
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      await expectLater(
        estimate(v1Message()),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode
                    .transactionFailedWhenSimulatingToEstimateResourceLimits,
              )
              .having((e) => e.context['cause'], 'cause', isA<SolanaError>()),
        ),
      );
    });

    test('wraps a transport failure with the estimation error code', () async {
      final rpc = createSolanaRpcFromTransport(
        (_) async => throw StateError('transport down'),
      );
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: rpc),
      );

      await expectLater(
        estimate(v1Message()),
        throwsA(
          isA<SolanaError>()
              .having(
                (e) => e.code,
                'code',
                SolanaErrorCode.transactionFailedToEstimateComputeLimit,
              )
              .having((e) => e.context['cause'], 'cause', isA<StateError>()),
        ),
      );
    });

    test('keeps the cause reachable through unwrapSimulationError', () async {
      // `unwrapSimulationError` unwraps the two "when simulating" codes. The
      // generic estimation failure is intentionally not one of them, so it is
      // returned unchanged and the original error stays in `context['cause']`.
      final rpc = createSolanaRpcFromTransport(
        (_) async => throw StateError('transport down'),
      );
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: rpc),
      );

      Object? thrown;
      try {
        await estimate(v1Message());
      } on Object catch (error) {
        thrown = error;
      }

      expect(unwrapSimulationError(thrown), same(thrown));
      expect(
        (thrown! as SolanaError).context['cause'],
        isA<StateError>(),
      );
    });

    test('unwraps a transaction failure to its decoded cause', () async {
      final fake = fakeRpc(
        result: simulationResult(
          err: {
            'InsufficientFundsForRent': {'account_index': 1},
          },
        ),
      );
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      Object? thrown;
      try {
        await estimate(v1Message());
      } on Object catch (error) {
        thrown = error;
      }

      // The "when simulating" code is one unwrapSimulationError understands.
      expect(unwrapSimulationError(thrown), isA<SolanaError>());
      expect(
        (unwrapSimulationError(thrown)! as SolanaError).code,
        isNot(
          equals(
            SolanaErrorCode
                .transactionFailedWhenSimulatingToEstimateResourceLimits,
          ),
        ),
      );
    });

    test('forwards commitment and minContextSlot to the node', () async {
      final fake = fakeRpc(result: simulationResult());
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      await estimate(
        v1Message(),
        EstimateResourceLimitsConfig(
          commitment: Commitment.confirmed,
          minContextSlot: BigInt.from(42),
        ),
      );

      final params = fake.requests.single['params']! as List<Object?>;
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], equals('confirmed'));
      expect(config['minContextSlot'], equals(BigInt.from(42)));
    });

    test('forwards an abort signal to the transport', () async {
      Future<void>? seenSignal;
      final rpc = createSolanaRpcFromTransport((config) async {
        seenSignal = config.signal;

        return <String, Object?>{
          'jsonrpc': '2.0',
          'id': (config.payload! as Map<String, Object?>)['id'],
          'result': simulationResult(),
        };
      });
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: rpc),
      );
      final abortSignal = Completer<void>();

      await estimate(
        v1Message(),
        EstimateResourceLimitsConfig(abortSignal: abortSignal.future),
      );

      expect(seenSignal, isNotNull);
    });

    test('throws when the response has no simulation value', () async {
      // A well-formed JSON-RPC envelope whose result lacks `value` cannot be
      // interpreted, so it reports the generic estimation failure.
      final fake = fakeRpc(result: <String, Object?>{'unexpected': true});
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      await expectLater(
        estimate(v1Message()),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.transactionFailedToEstimateComputeLimit,
          ),
        ),
      );
    });

    test('accepts a compute unit count the node reported as an int', () async {
      final fake = fakeRpc(result: simulationResult(unitsConsumed: 4242));
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );

      final limits = await estimate(v1Message());

      expect(limits.computeUnitLimit, equals(4242));
    });

    test(
      'accepts a loaded accounts size the node reported as a BigInt',
      () async {
        final fake = fakeRpc(
          result: simulationResult(loadedAccountsDataSize: BigInt.from(1024)),
        );
        final estimate = estimateResourceLimitsFactory(
          EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
        );

        final limits = await estimate(v1Message());

        expect(limits.loadedAccountsDataSizeLimit, equals(1024));
      },
    );

    test(
      'reports no loaded accounts size for legacy when the node omits it',
      () async {
        final fake = fakeRpc(
          result: simulationResult(loadedAccountsDataSize: null),
        );
        final estimate = estimateResourceLimitsFactory(
          EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
        );

        final limits = await estimate(legacyMessage());

        expect(limits.computeUnitLimit, equals(5000));
        expect(limits.loadedAccountsDataSizeLimit, isNull);
      },
    );
  });

  group('estimateAndSetResourceLimitsFactory', () {
    test('replaces provisory limits with simulated values', () async {
      final fake = fakeRpc(
        result: simulationResult(
          unitsConsumed: 7777,
          loadedAccountsDataSize: 3333,
        ),
      );
      final estimator = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );
      final estimateAndSet = estimateAndSetResourceLimitsFactory(estimator);

      final message = fillTransactionMessageProvisoryResourceLimits(
        v1Message(),
      );
      final updated = await estimateAndSet(message);

      expect(getTransactionMessageComputeUnitLimit(updated), equals(7777));
      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        equals(3333),
      );
    });

    test('skips the simulation when every limit is already explicit', () async {
      final fake = fakeRpc(result: simulationResult());
      final estimator = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: fake.rpc),
      );
      final estimateAndSet = estimateAndSetResourceLimitsFactory(estimator);

      final message = setTransactionMessageConfig(
        const V1TransactionConfig(
          computeUnitLimit: 250000,
          loadedAccountsDataSizeLimit: 65536,
        ),
        v1Message(),
      );
      final updated = await estimateAndSet(message);

      expect(fake.requests, isEmpty);
      expect(getTransactionMessageComputeUnitLimit(updated), equals(250000));
    });
  });
}
