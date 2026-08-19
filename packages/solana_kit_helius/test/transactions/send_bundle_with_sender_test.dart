import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:solana_kit_helius/src/internal/json_rpc_client.dart';
import 'package:solana_kit_helius/src/transactions/send_bundle_with_sender.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('sendBundleWithSender', () {
    test(
      'posts a sendBundle request and returns signatures in order',
      () async {
        final requests = <http.Request>[];
        final httpClient = MockClient((request) async {
          requests.add(request);
          expect(request.url.toString(), 'https://sender.helius-rpc.com/fast');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'sendBundle');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as List<Object?>;
          expect(params[0], isA<List<Object?>>());
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': '1',
              'result': 'bundle-id',
            }),
            200,
          );
        });

        final rpcClient = JsonRpcClient(
          url: 'https://api.helius-rpc.com',
          client: MockClient((request) async {
            final body = jsonDecode(request.body) as Map<String, Object?>;
            expect(body['method'], 'getSignatureStatuses');
            return http.Response(
              jsonEncode(<String, Object?>{
                'jsonrpc': '2.0',
                'id': 1,
                'result': {
                  'value': [
                    {
                      'confirmationStatus': 'confirmed',
                      'err': null,
                    },
                  ],
                },
              }),
              200,
            );
          }),
        );

        final sigs = await sendBundleWithSender(
          httpClient,
          rpcClient,
          [_signedTx(1), _signedTx(2)],
        );

        expect(requests, hasLength(1));
        expect(sigs, [_expectedSig(1), _expectedSig(2)]);
      },
    );

    test('rejects empty bundles and bundles larger than 5', () async {
      final httpClient = MockClient(
        (request) async => http.Response('{}', 200),
      );
      final rpcClient = JsonRpcClient(
        url: 'https://api.helius-rpc.com',
        client: MockClient((request) async => http.Response('{}', 200)),
      );
      expect(
        () => sendBundleWithSender(httpClient, rpcClient, []),
        throwsArgumentError,
      );
      expect(
        () => sendBundleWithSender(
          httpClient,
          rpcClient,
          List.generate(6, _signedTx),
        ),
        throwsArgumentError,
      );
    });

    test('surfaces RPC errors from the Sender endpoint', () async {
      final httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': '1',
            'error': {'code': -32601, 'message': 'method not found'},
          }),
          200,
        );
      });
      final rpcClient = JsonRpcClient(
        url: 'https://api.helius-rpc.com',
        client: MockClient((request) async => http.Response('{}', 200)),
      );
      expect(
        () => sendBundleWithSender(httpClient, rpcClient, [_signedTx(1)]),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('method not found'),
          ),
        ),
      );
    });

    test('throws on a non-200 HTTP response from Sender', () async {
      final httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': '1',
            'result': 'bundle-id',
          }),
          500,
        );
      });
      final rpcClient = JsonRpcClient(
        url: 'https://api.helius-rpc.com',
        client: MockClient((request) async => http.Response('{}', 200)),
      );
      await expectLater(
        sendBundleWithSender(httpClient, rpcClient, [_signedTx(1)]),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Sender bundle HTTP 500'),
          ),
        ),
      );
    });

    test('polls getSignatureStatuses until the bundle confirms', () async {
      var statusCalls = 0;
      final httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': '1',
            'result': 'bundle-id',
          }),
          200,
        );
      });
      final rpcClient = JsonRpcClient(
        url: 'https://api.helius-rpc.com',
        client: MockClient((request) async {
          statusCalls++;
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': {
                'value': [
                  {
                    'confirmationStatus': statusCalls == 1
                        ? 'processed'
                        : 'finalized',
                  },
                ],
              },
            }),
            200,
          );
        }),
      );

      final sigs = await sendBundleWithSender(
        httpClient,
        rpcClient,
        [_signedTx(1)],
        options: const SendBundleOptions(pollIntervalMs: 10),
      );
      expect(statusCalls, 2);
      expect(sigs, [_expectedSig(1)]);
    });

    test('throws when the bundle never confirms', () async {
      final httpClient = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': '1',
            'result': 'bundle-id',
          }),
          200,
        );
      });
      final rpcClient = JsonRpcClient(
        url: 'https://api.helius-rpc.com',
        client: MockClient((request) async {
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': {
                'value': [
                  {'confirmationStatus': 'processed'},
                ],
              },
            }),
            200,
          );
        }),
      );

      await expectLater(
        sendBundleWithSender(
          httpClient,
          rpcClient,
          [_signedTx(1)],
          options: const SendBundleOptions(
            pollTimeoutMs: 60,
            pollIntervalMs: 20,
          ),
        ),
        throwsA(isA<SolanaError>()),
      );
    });
  });
}

Transaction _signedTx(int n) => Transaction(
  messageBytes: Uint8List.fromList(List.generate(64, (i) => i + n)),
  signatures: {
    const Address('11111111111111111111111111111111'): SignatureBytes(
      Uint8List.fromList(List.generate(64, (i) => i + n)),
    ),
  },
);

String _expectedSig(int n) => getSignatureFromTransaction(_signedTx(n)).value;
