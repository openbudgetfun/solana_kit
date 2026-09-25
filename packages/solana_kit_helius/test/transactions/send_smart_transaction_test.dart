import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.sendSmartTransaction', () {
    test('orchestrates sendTransaction and getSignatureStatuses', () async {
      var callCount = 0;
      final client = MockClient((request) async {
        callCount++;
        final body = jsonDecode(request.body) as Map<String, Object?>;
        if (body['method'] == 'sendTransaction') {
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': 'sig-abc',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        // getSignatureStatuses
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 2,
            'result': <String, Object?>{
              'value': <Object?>[
                <String, Object?>{
                  'confirmationStatus': 'confirmed',
                  'err': null,
                },
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.transactions.sendSmartTransaction(
        const SendSmartTransactionInput(
          instructions: <Object?>['instr1'],
          skipPreflight: true,
        ),
      );

      expect(result.signature, 'sig-abc');
      expect(result.confirmationStatus, 'confirmed');
      expect(callCount, greaterThanOrEqualTo(2));
    });

    test('propagates RPC error from sendTransaction', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'error': <String, Object?>{
              'code': -32000,
              'message': 'Transaction simulation failed',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.transactions.sendSmartTransaction(
          const SendSmartTransactionInput(
            instructions: <Object?>['AQIDBA=='],
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects a submission with no serialized transaction', () async {
      final har = _harness((_) => null);

      expect(
        () => har.helius.transactions.sendSmartTransaction(
          const SendSmartTransactionInput(instructions: <Object?>[]),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('expected a base64-encoded transaction'),
          ),
        ),
      );
      expect(
        har.methods,
        isEmpty,
        reason: 'an unsubmittable payload must fail before any round trip',
      );
    });

    test(
      'submits the serialized transaction as the first RPC parameter',
      () async {
        List<Object?>? sentParams;
        final client = MockClient((request) async {
          final body = jsonDecode(request.body) as Map<String, Object?>;
          if (body['method'] == 'sendTransaction') {
            sentParams = body['params']! as List<Object?>;

            return http.Response(
              jsonEncode(<String, Object?>{
                'jsonrpc': '2.0',
                'id': 1,
                'result': 'sig-xyz',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }

          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 2,
              'result': <String, Object?>{
                'value': <Object?>[
                  <String, Object?>{'confirmationStatus': 'confirmed'},
                ],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.transactions.sendSmartTransaction(
          const SendSmartTransactionInput(
            instructions: <Object?>['AQIDBA=='],
            skipPreflight: false,
            maxRetries: 3,
          ),
        );

        expect(sentParams!.first, equals('AQIDBA=='));
        final config = sentParams![1]! as Map<String, Object?>;
        expect(config['skipPreflight'], isFalse);
        expect(config['maxRetries'], equals(3));
        expect(result.signature, equals('sig-xyz'));
      },
    );
  });
}

/// Records every JSON-RPC method the client calls.
({HeliusClient helius, List<String> methods}) _harness(
  Object? Function(String method) handler,
) {
  final methods = <String>[];
  final client = MockClient((request) async {
    final body = jsonDecode(request.body) as Map<String, Object?>;
    methods.add(body['method']! as String);

    return http.Response(
      handler(body['method']! as String) as String? ??
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'error': <String, Object?>{'code': -32601, 'message': 'not found'},
          }),
      200,
      headers: {'content-type': 'application/json'},
    );
  });

  return (
    helius: createHelius(HeliusConfig(apiKey: 'test-key'), client: client),
    methods: methods,
  );
}
