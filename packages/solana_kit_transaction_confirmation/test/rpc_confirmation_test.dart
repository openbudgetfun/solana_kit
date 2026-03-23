import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc/solana_kit_rpc.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:solana_kit_rpc_subscriptions_channel_websocket/solana_kit_rpc_subscriptions_channel_websocket.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_transaction_confirmation/solana_kit_transaction_confirmation.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('waitForTransactionConfirmation', () {
    test(
      'confirms a blockhash lifetime transaction via signature polling',
      () async {
        final transport = _ScriptedRpcTransport(
          queuedResults: {
            'getSignatureStatuses': [
              _signatureStatusesResponse([null]),
              _signatureStatusesResponse([
                const {'confirmationStatus': 'confirmed', 'err': null},
              ]),
            ],
          },
          fallbackResults: {
            'getEpochInfo': _epochInfoResponse(blockHeight: 90),
          },
        );
        final rpc = createSolanaRpcFromTransport(transport.call);

        await waitForTransactionConfirmation(
          rpc: rpc,
          signature: const Signature(_signatureValue),
          transaction: _blockhashTransaction(),
          config: const RpcTransactionConfirmationConfig(
            pollInterval: Duration.zero,
            searchTransactionHistory: true,
          ),
        );

        final getSignatureStatusesPayload = transport
            .payloadsFor('getSignatureStatuses')
            .first;
        expect(getSignatureStatusesPayload['params'], [
          [_signatureValue],
          {'searchTransactionHistory': true},
        ]);
      },
    );

    test(
      'throws when block height exceeds the last valid block height',
      () async {
        final transport = _ScriptedRpcTransport(
          fallbackResults: {
            'getSignatureStatuses': _signatureStatusesResponse([null]),
            'getEpochInfo': _epochInfoResponse(blockHeight: 101),
          },
        );
        final rpc = createSolanaRpcFromTransport(transport.call);

        await expectLater(
          () => waitForTransactionConfirmation(
            rpc: rpc,
            signature: const Signature(_signatureValue),
            transaction: _blockhashTransaction(
              lastValidBlockHeight: BigInt.from(100),
            ),
            config: const RpcTransactionConfirmationConfig(
              pollInterval: Duration.zero,
            ),
          ),
          throwsA(
            isA<SolanaError>()
                .having(
                  (error) => error.code,
                  'code',
                  SolanaErrorCode.blockHeightExceeded,
                )
                .having(
                  (error) => error.context['lastValidBlockHeight'],
                  'lastValidBlockHeight',
                  BigInt.from(100),
                ),
          ),
        );
      },
    );

    test(
      'confirms a durable nonce transaction while the nonce remains valid',
      () async {
        final transport = _ScriptedRpcTransport(
          queuedResults: {
            'getSignatureStatuses': [
              _signatureStatusesResponse([null]),
              _signatureStatusesResponse([
                const {'confirmationStatus': 'finalized', 'err': null},
              ]),
            ],
          },
          fallbackResults: {
            'getAccountInfo': _nonceAccountInfoResponse(_expectedNonceValue),
          },
        );
        final rpc = createSolanaRpcFromTransport(transport.call);

        await waitForTransactionConfirmation(
          rpc: rpc,
          signature: const Signature(_signatureValue),
          transaction: _durableNonceTransaction(),
          config: const RpcTransactionConfirmationConfig(
            pollInterval: Duration.zero,
          ),
        );
      },
    );

    test('throws when the durable nonce account value changes', () async {
      final transport = _ScriptedRpcTransport(
        fallbackResults: {
          'getSignatureStatuses': _signatureStatusesResponse([null]),
          'getAccountInfo': _nonceAccountInfoResponse(
            '22222222222222222222222222222222',
          ),
        },
      );
      final rpc = createSolanaRpcFromTransport(transport.call);

      await expectLater(
        () => waitForTransactionConfirmation(
          rpc: rpc,
          signature: const Signature(_signatureValue),
          transaction: _durableNonceTransaction(),
          config: const RpcTransactionConfirmationConfig(
            pollInterval: Duration.zero,
          ),
        ),
        throwsA(
          isA<SolanaError>()
              .having(
                (error) => error.code,
                'code',
                SolanaErrorCode.invalidNonce,
              )
              .having(
                (error) => error.context['expectedNonceValue'],
                'expectedNonceValue',
                _expectedNonceValue,
              ),
        ),
      );
    });

    test('throws when the operation is aborted mid-poll', () async {
      final abortController = AbortController();
      final transport = _ScriptedRpcTransport(
        onRequest: (method, callIndex, _) {
          if (method == 'getSignatureStatuses' && callIndex == 1) {
            abortController.abort('stop polling');
          }
          if (method == 'getSignatureStatuses') {
            return _signatureStatusesResponse([null]);
          }
          return _epochInfoResponse(blockHeight: 90);
        },
      );
      final rpc = createSolanaRpcFromTransport(transport.call);

      await expectLater(
        () => waitForTransactionConfirmation(
          rpc: rpc,
          signature: const Signature(_signatureValue),
          transaction: _blockhashTransaction(),
          config: RpcTransactionConfirmationConfig(
            abortSignal: abortController.signal,
            pollInterval: Duration.zero,
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('stop polling'),
          ),
        ),
      );
    });

    test('throws for transactions without lifetime metadata', () async {
      final rpc = createSolanaRpcFromTransport((_) async {
        throw StateError('transport should not be called');
      });

      await expectLater(
        () => waitForTransactionConfirmation(
          rpc: rpc,
          signature: const Signature(_signatureValue),
          transaction: Transaction(
            messageBytes: Uint8List.fromList([1, 2, 3]),
            signatures: {_feePayer: _signatureBytes},
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('TransactionWithLifetime'),
          ),
        ),
      );
    });
  });

  group('sendAndConfirmTransaction', () {
    test('sends base64 wire bytes then waits for confirmation', () async {
      final transaction = _blockhashTransaction();
      final expectedWire = getBase64EncodedWireTransaction(transaction);
      final transport = _ScriptedRpcTransport(
        queuedResults: {
          'getSignatureStatuses': [
            _signatureStatusesResponse([
              const {'confirmationStatus': 'finalized', 'err': null},
            ]),
          ],
        },
        fallbackResults: {
          'sendTransaction': _signatureValue,
          'getEpochInfo': _epochInfoResponse(blockHeight: 90),
        },
      );
      final rpc = createSolanaRpcFromTransport(transport.call);

      final signature = await sendAndConfirmTransaction(
        rpc: rpc,
        transaction: transaction,
        config: const SendAndConfirmTransactionConfig(
          commitment: Commitment.processed,
          pollInterval: Duration.zero,
          skipPreflight: true,
        ),
      );

      expect(signature.value, _signatureValue);

      final sendPayload = transport.singlePayloadFor('sendTransaction');
      expect(sendPayload['params'], [
        expectedWire,
        {'skipPreflight': true, 'preflightCommitment': 'processed'},
      ]);
    });

    test(
      'throws before sending when the transaction is not fully signed',
      () async {
        final rpc = createSolanaRpcFromTransport((_) async {
          throw StateError('transport should not be called');
        });

        await expectLater(
          () => sendAndConfirmTransaction(
            rpc: rpc,
            transaction: TransactionWithLifetime(
              messageBytes: Uint8List.fromList([1, 2, 3]),
              signatures: {_feePayer: null},
              lifetimeConstraint: TransactionBlockhashLifetime(
                blockhash: _expectedNonceValue,
                lastValidBlockHeight: BigInt.zero,
              ),
            ),
          ),
          throwsA(
            isA<SolanaError>().having(
              (error) => error.code,
              'code',
              SolanaErrorCode.transactionSignaturesMissing,
            ),
          ),
        );
      },
    );
  });
}

const Address _feePayer = Address('11111111111111111111111111111111');
const String _expectedNonceValue = '11111111111111111111111111111111';
const String _signatureValue =
    '1111111111111111111111111111111111111111111111111111111111111111';
final SignatureBytes _signatureBytes = signatureBytes(Uint8List(64));

TransactionWithLifetime _blockhashTransaction({BigInt? lastValidBlockHeight}) {
  return TransactionWithLifetime(
    messageBytes: Uint8List.fromList([1, 2, 3]),
    signatures: {_feePayer: _signatureBytes},
    lifetimeConstraint: TransactionBlockhashLifetime(
      blockhash: _expectedNonceValue,
      lastValidBlockHeight: lastValidBlockHeight ?? BigInt.from(100),
    ),
  );
}

TransactionWithLifetime _durableNonceTransaction() {
  return TransactionWithLifetime(
    messageBytes: Uint8List.fromList([4, 5, 6]),
    signatures: {_feePayer: _signatureBytes},
    lifetimeConstraint: const TransactionDurableNonceLifetime(
      nonce: _expectedNonceValue,
      nonceAccountAddress: _feePayer,
    ),
  );
}

Map<String, Object?> _signatureStatusesResponse(List<Object?> value) {
  return {
    'context': {'slot': 1},
    'value': value,
  };
}

Map<String, Object?> _epochInfoResponse({required int blockHeight}) {
  return {
    'absoluteSlot': blockHeight + 5,
    'blockHeight': blockHeight,
    'epoch': 1,
    'slotIndex': 1,
    'slotsInEpoch': 32,
  };
}

Map<String, Object?> _nonceAccountInfoResponse(String nonceValue) {
  return {
    'context': {'slot': 1},
    'value': {
      'data': {
        'parsed': {
          'info': {'blockhash': nonceValue},
        },
      },
    },
  };
}

class _ScriptedRpcTransport {
  _ScriptedRpcTransport({
    Map<String, List<Object?>>? queuedResults,
    Map<String, Object?>? fallbackResults,
    this.onRequest,
  }) : _queuedResults = {
         for (final entry in (queuedResults ?? const {}).entries)
           entry.key: List<Object?>.from(entry.value),
       },
       _fallbackResults = Map<String, Object?>.from(
         fallbackResults ?? const {},
       );

  final Map<String, List<Object?>> _queuedResults;
  final Map<String, Object?> _fallbackResults;
  final Object? Function(String method, int callIndex, List<Object?> params)?
  onRequest;

  final List<Map<String, Object?>> payloads = <Map<String, Object?>>[];
  final Map<String, int> _callCounts = <String, int>{};

  Future<Object?> call(RpcTransportConfig config) async {
    final payload = Map<String, Object?>.from(
      config.payload! as Map<String, Object?>,
    );
    payloads.add(payload);

    final method = payload['method']! as String;
    final params = payload['params'] as List<Object?>? ?? const <Object?>[];
    final callIndex = (_callCounts[method] ?? 0) + 1;
    _callCounts[method] = callIndex;

    final result =
        onRequest?.call(method, callIndex, params) ?? _nextResult(method);

    return {'jsonrpc': '2.0', 'id': payload['id'] ?? '1', 'result': result};
  }

  List<Map<String, Object?>> payloadsFor(String method) {
    return payloads
        .where((payload) => payload['method'] == method)
        .toList(growable: false);
  }

  Map<String, Object?> singlePayloadFor(String method) {
    return payloadsFor(method).single;
  }

  Object? _nextResult(String method) {
    final queue = _queuedResults[method];
    if (queue != null && queue.isNotEmpty) {
      return queue.removeAt(0);
    }
    if (_fallbackResults.containsKey(method)) {
      return _fallbackResults[method];
    }
    throw StateError('Unexpected RPC method: $method');
  }
}
