import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.createSmartTransaction', () {
    test('sends getLatestBlockhash RPC and returns blockhash', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getLatestBlockhash');
        expect(body['jsonrpc'], '2.0');
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{
              'value': <String, Object?>{
                'blockhash': 'bh123',
                'lastValidBlockHeight': 1000,
              },
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

      final blockhash = await helius.transactions.createSmartTransaction(
        CreateSmartTransactionInput(instructions: <Object?>['instr1']),
      );

      expect(blockhash, 'bh123');
    });

    test('throws on RPC error response', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'error': <String, Object?>{
              'code': -32600,
              'message': 'Invalid Request',
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
        () => helius.transactions.createSmartTransaction(
          CreateSmartTransactionInput(instructions: <Object?>[]),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
