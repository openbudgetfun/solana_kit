/// Live WebSocket compatibility contracts for Solana RPC subscriptions.
///
/// These tests use Surfpool's actual WebSocket endpoint. They verify both the
/// notification payloads consumed by applications and cancellation, which
/// must issue the matching unsubscribe request and close the Dart stream.
@TestOn('vm')
@Tags(['integration'])
library;

import 'dart:async';

import 'package:solana_kit_integration_tests/solana_kit_integration_tests.dart';
import 'package:solana_kit_rpc_subscriptions/solana_kit_rpc_subscriptions.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart'
    hide TransactionVersion;
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:solana_kit_system/solana_kit_system.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  late IntegrationTestEnv env;
  late SurfpoolClient client;

  setUpAll(() async {
    env = await IntegrationTestEnv.create();
    client = connectSurfpoolClient(
      rpcUrl: env.surfnet.rpcUri,
      wsUrl: env.surfnet.wsUri,
      payer: env.payer,
    );
  });

  tearDownAll(() async {
    await client.stop();
    await env.dispose();
  });

  test(
    'accountSubscribe reports the confirmed on-chain balance and cancels cleanly',
    () async {
      // An account begins with a rent-exempt balance. The subscription is open
      // before a System transfer, so the first notification after submission
      // must name the new confirmed balance. Cancelling must close the stream.
      final recipient = generateKeyPairSigner().address;
      const initialLamports = 1_000_000;
      const transferredLamports = 1_500_000;
      await env.surfnet.fundSol(recipient, initialLamports);

      final source = CancellationTokenSource();
      final stream = await client.rpcSubscriptions
          .accountNotifications(
            recipient,
            const AccountNotificationsConfig(
              commitment: Commitment.confirmed,
              encoding: AccountEncoding.base64,
            ),
          )
          .subscribe(RpcSubscribeOptions(abortSignal: source.token));
      final notification = Completer<Object?>();
      final closed = Completer<void>();
      final subscription = stream.listen(
        (value) {
          if (!notification.isCompleted) notification.complete(value);
        },
        onError: notification.completeError,
        onDone: closed.complete,
      );

      try {
        await env.sendInstructions([
          getTransferSolInstruction(
            programAddress: systemProgramAddress,
            source: env.payer.address,
            destination: recipient,
            amount: BigInt.from(transferredLamports),
          ),
        ]);

        final result = await notification.future.timeout(
          const Duration(seconds: 5),
        );
        final response = result! as Map<String, Object?>;
        final context = response['context']! as Map<String, Object?>;
        final account = response['value']! as Map<String, Object?>;
        expect(context['slot'], isA<BigInt>());
        expect(
          account['lamports'],
          BigInt.from(initialLamports + transferredLamports),
        );
        expect(account['owner'], systemProgramAddress.value);

        source.cancel();
        await closed.future.timeout(const Duration(seconds: 5));
      } finally {
        source.cancel();
        await subscription.cancel();
      }
    },
  );

  test(
    'signatureSubscribe reports successful confirmation and cancels cleanly',
    () async {
      // The transaction is signed before subscribing, as a wallet or relay
      // would do. Surfpool must accept that exact wire transaction and publish
      // a terminal notification whose `err` is null for the same signature.
      final transaction = await _signedTransfer(env);
      final expectedSignature = getSignatureFromTransaction(transaction);
      final source = CancellationTokenSource();
      final stream = await client.rpcSubscriptions
          .signatureNotifications(
            expectedSignature,
            const SignatureNotificationsConfig(
              commitment: Commitment.confirmed,
            ),
          )
          .subscribe(RpcSubscribeOptions(abortSignal: source.token));
      final notification = Completer<Object?>();
      final closed = Completer<void>();
      final subscription = stream.listen(
        (value) {
          if (!notification.isCompleted) notification.complete(value);
        },
        onError: notification.completeError,
        onDone: closed.complete,
      );

      try {
        final submittedSignature = await sendAndConfirmTransaction(
          rpc: env.rpc,
          transaction: transaction,
        );
        expect(submittedSignature, expectedSignature);

        final result = await notification.future.timeout(
          const Duration(seconds: 5),
        );
        final response = result! as Map<String, Object?>;
        final context = response['context']! as Map<String, Object?>;
        final value = response['value']! as Map<String, Object?>;
        expect(context['slot'], isA<BigInt>());
        expect(value['err'], isNull);

        source.cancel();
        await closed.future.timeout(const Duration(seconds: 5));
      } finally {
        source.cancel();
        await subscription.cancel();
      }
    },
  );
}

Future<TransactionWithLifetime> _signedTransfer(IntegrationTestEnv env) async {
  final recipient = generateKeyPairSigner().address;
  final message = TransactionMessageWithFeePayerSigner(
    feePayerSigner: env.payer,
    version: TransactionVersion.v0,
    instructions: [
      addSignersToInstruction(
        [env.payer],
        getTransferSolInstruction(
          programAddress: systemProgramAddress,
          source: env.payer.address,
          destination: recipient,
          amount: BigInt.from(1_500_000),
        ),
      ),
    ],
    lifetimeConstraint: await env.recentBlockhashLifetime(),
  );
  final compiled = compileTransaction(message);
  final signed = await signTransactionMessageWithSigners(message);
  return TransactionWithLifetime(
    messageBytes: signed.messageBytes,
    signatures: signed.signatures,
    lifetimeConstraint: compiled.lifetimeConstraint,
  );
}
