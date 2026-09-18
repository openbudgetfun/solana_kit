/// On-chain integration tests for the simulate-based resource-limit estimator.
///
/// `estimateResourceLimitsFactory` is the only supported way to obtain the
/// compute unit and loaded accounts data size limits that a version 1
/// transaction must state explicitly: v1 budgets zero for both when the config
/// is empty, so an unestimated v1 transaction fails at execution. These tests
/// run the estimator against a real SurfPool validator and submit the result,
/// which is the only way to prove the limits it returns are executable rather
/// than merely well-formed.
///
/// Run via the `test:integration` workspace script (which starts SurfPool) or
/// directly — `IntegrationTestEnv.create` starts a SurfPool instance when one
/// is not already running.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:typed_data';

import 'package:solana_kit/solana_kit.dart';
import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:test/test.dart';

/// A memo large enough that its transaction cannot fit the legacy 1232-byte
/// ceiling but comfortably fits the v1 4096-byte ceiling.
const _oversizedMemoLength = 1600;

void main() {
  late IntegrationTestEnv env;

  setUpAll(() async {
    env = await IntegrationTestEnv.create(payerLamports: 100_000_000_000);
  });

  tearDownAll(() => env.dispose());

  /// Builds a v1 memo message whose limits are left unset.
  TransactionMessage unestimatedV1Message({int memoLength = 32}) {
    return TransactionMessageWithFeePayerSigner(
      feePayerSigner: env.payer,
      version: TransactionVersion.v1,
      instructions: [
        Instruction(
          programAddress: onChainMemoProgramAddress,
          accounts: const [],
          data: Uint8List(memoLength)..fillRange(0, memoLength, 0x41),
        ),
      ],
      lifetimeConstraint: BlockhashLifetimeConstraint(
        blockhash: '11111111111111111111111111111111',
        lastValidBlockHeight: BigInt.from(1000),
      ),
    );
  }

  group('resource-limit estimation against a live validator', () {
    test(
      'returns a compute unit limit above what the transaction needs',
      () async {
        final estimate = estimateResourceLimitsFactory(
          EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
        );

        final limits = await estimate(
          unestimatedV1Message(),
        );

        // A memo costs a small handful of units; the estimate must be positive
        // and well under the 1.4M ceiling.
        expect(limits.computeUnitLimit, greaterThan(0));
        expect(limits.computeUnitLimit, lessThan(maxComputeUnitLimit));
      },
    );

    test('returns the loaded accounts data size that v1 requires', () async {
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
      );

      final limits = await estimate(unestimatedV1Message());

      // v1 budgets zero bytes when this is absent, so the estimator must
      // always produce a usable value for a v1 message.
      expect(limits.loadedAccountsDataSizeLimit, isNotNull);
      expect(limits.loadedAccountsDataSizeLimit, greaterThan(0));
    });

    test('never gives a legacy message a loaded accounts limit', () async {
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
      );

      final legacyMessage = TransactionMessageWithFeePayerSigner(
        feePayerSigner: env.payer,
        version: TransactionVersion.legacy,
        instructions: [
          Instruction(
            programAddress: onChainMemoProgramAddress,
            accounts: const [],
            data: Uint8List(8),
          ),
        ],
        lifetimeConstraint: await env.recentBlockhashLifetime(),
      );

      final limits = await estimate(legacyMessage);

      // The compute unit limit is always returned. The loaded accounts size is
      // optional for legacy and v0, so whichever the node reports is accepted;
      // the contract that matters is that a legacy message never gains the
      // limit, because the runtime only honours it for version 1.
      expect(limits.computeUnitLimit, greaterThan(0));

      final updated = await estimateAndSetResourceLimitsFactory(estimate)(
        legacyMessage,
      );
      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(updated),
        isNull,
        reason: 'a legacy message must never gain a loaded accounts limit',
      );
    });

    test('a v1 transaction carrying estimated limits lands on-chain', () async {
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
      );
      final estimateAndSet = estimateAndSetResourceLimitsFactory(estimate);

      var message = unestimatedV1Message(memoLength: _oversizedMemoLength);
      final latest = await env.rpc.getLatestBlockhashValue().send();
      message = message.copyWith(
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: latest.value.blockhash.value,
          lastValidBlockHeight: latest.value.lastValidBlockHeight,
        ),
      );

      final estimated = await estimateAndSet(message);

      // The estimator must have filled both limits.
      expect(getTransactionMessageComputeUnitLimit(estimated), greaterThan(0));
      expect(
        getTransactionMessageLoadedAccountsDataSizeLimit(estimated),
        greaterThan(0),
      );

      final signed = await signTransactionMessageWithSigners(estimated);
      final signature = await env.rpc
          .sendTransaction(
            getBase64EncodedWireTransaction(signed),
            const SendTransactionConfig(
              encoding: WireTransactionEncoding.base64,
              skipPreflight: true,
            ),
          )
          .send();

      await Future<void>.delayed(const Duration(seconds: 1));

      final statuses = await env.rpc.getSignatureStatuses([
        Signature(signature),
      ]).send();
      final entry =
          (statuses['value']! as List<Object?>).single! as Map<String, Object?>;
      expect(
        entry['err'],
        isNull,
        reason: 'a transaction with estimated limits must execute',
      );
    });

    test('an unestimated v1 message encodes a zero-budget config', () async {
      // The contrast that justifies the estimator's existence. A v1 message
      // with no estimated limits encodes an empty config mask, which the
      // runtime reads as a zero compute budget and zero loaded account bytes.
      // This SurfPool build does not enforce that rejection, so the assertion
      // is on the encoded message rather than on a validator verdict.
      final latest = await env.rpc.getLatestBlockhashValue().send();
      final message = unestimatedV1Message(memoLength: _oversizedMemoLength)
          .copyWith(
            lifetimeConstraint: BlockhashLifetimeConstraint(
              blockhash: latest.value.blockhash.value,
              lastValidBlockHeight: latest.value.lastValidBlockHeight,
            ),
          );

      final compiled = compileTransactionMessage(message);
      expect(compiled.configMask, equals(0));
      expect(compiled.configValues, isEmpty);

      // After estimation the same message carries a populated config, which is
      // what makes it executable.
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
      );
      final estimated = await estimateAndSetResourceLimitsFactory(estimate)(
        message,
      );
      final estimatedCompiled = compileTransactionMessage(estimated);
      expect(estimatedCompiled.configMask, isNot(equals(0)));
      expect(estimatedCompiled.configValues, isNotEmpty);
    });

    test(
      'estimates a larger transaction into a larger compute budget',
      () async {
        final estimate = estimateResourceLimitsFactory(
          EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
        );
        final latest = await env.rpc.getLatestBlockhashValue().send();

        TransactionMessage withMemo(int length) =>
            unestimatedV1Message(memoLength: length).copyWith(
              lifetimeConstraint: BlockhashLifetimeConstraint(
                blockhash: latest.value.blockhash.value,
                lastValidBlockHeight: latest.value.lastValidBlockHeight,
              ),
            );

        final small = await estimate(withMemo(32));
        final large = await estimate(withMemo(_oversizedMemoLength));

        // Estimating 1600 bytes of memo must cost at least as many units as 32.
        expect(
          large.computeUnitLimit,
          greaterThanOrEqualTo(small.computeUnitLimit),
        );
        expect(large.loadedAccountsDataSizeLimit, isNotNull);
      },
    );

    test('a v1 transfer with estimated limits moves lamports', () async {
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
      );
      final estimateAndSet = estimateAndSetResourceLimitsFactory(estimate);
      final recipient = generateKeyPairSigner();
      final latest = await env.rpc.getLatestBlockhashValue().send();

      final message = TransactionMessageWithFeePayerSigner(
        feePayerSigner: env.payer,
        version: TransactionVersion.v1,
        instructions: [
          getTransferSolInstruction(
            programAddress: systemProgramAddress,
            source: env.payer.address,
            destination: recipient.address,
            amount: BigInt.from(50000000),
          ),
        ],
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: latest.value.blockhash.value,
          lastValidBlockHeight: latest.value.lastValidBlockHeight,
        ),
      );

      final estimated = await estimateAndSet(message);
      final signed = await signTransactionMessageWithSigners(estimated);
      await env.rpc
          .sendTransaction(
            getBase64EncodedWireTransaction(signed),
            const SendTransactionConfig(
              encoding: WireTransactionEncoding.base64,
              skipPreflight: true,
            ),
          )
          .send();

      await Future<void>.delayed(const Duration(seconds: 1));

      final balance = await env.rpc.getBalanceValue(recipient.address).send();
      expect(balance.value, equals(BigInt.from(50000000)));
    });

    test('a transaction failure surfaces through the simulation error', () async {
      final estimate = estimateResourceLimitsFactory(
        EstimateResourceLimitsFactoryConfig(rpc: env.rpc),
      );
      final latest = await env.rpc.getLatestBlockhashValue().send();

      // Funding an unfunded payer cannot succeed, so the estimator must report
      // the transaction error rather than a bare units count.
      final broke = generateKeyPairSigner();
      final message = TransactionMessageWithFeePayerSigner(
        feePayerSigner: broke,
        version: TransactionVersion.v1,
        instructions: [
          getTransferSolInstruction(
            programAddress: systemProgramAddress,
            source: broke.address,
            destination: env.payer.address,
            amount: BigInt.from(1),
          ),
        ],
        lifetimeConstraint: BlockhashLifetimeConstraint(
          blockhash: latest.value.blockhash.value,
          lastValidBlockHeight: latest.value.lastValidBlockHeight,
        ),
      );

      await expectLater(
        estimate(message),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            isIn(<SolanaErrorCode>[
              SolanaErrorCode
                  .transactionFailedWhenSimulatingToEstimateResourceLimits,
              SolanaErrorCode.transactionFailedToEstimateComputeLimit,
            ]),
          ),
        ),
      );
    });
  });
}
