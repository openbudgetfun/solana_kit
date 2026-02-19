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
        SendSmartTransactionInput(
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
          SendSmartTransactionInput(instructions: <Object?>[]),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
