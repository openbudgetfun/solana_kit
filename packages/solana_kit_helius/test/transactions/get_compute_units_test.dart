import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionsClient.getComputeUnits', () {
    test(
      'sends simulateTransaction RPC and deserializes compute units',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'simulateTransaction');
          expect(body['jsonrpc'], '2.0');
          final params = body['params']! as List<Object?>;
          expect(params.length, 2);
          final options = params[1]! as Map<String, Object?>;
          expect(options['replaceRecentBlockhash'], true);
          expect(options['sigVerify'], false);
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': <String, Object?>{
                'value': <String, Object?>{'unitsConsumed': 150000},
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          const HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final estimate = await helius.transactions.getComputeUnits(
          const CreateSmartTransactionInput(
            instructions: <Object?>['instruction1'],
          ),
        );

        expect(estimate.units, 150000);
      },
    );

    test('defaults to 200000 when unitsConsumed is null', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': <String, Object?>{'value': <String, Object?>{}},
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final estimate = await helius.transactions.getComputeUnits(
        const CreateSmartTransactionInput(instructions: <Object?>[]),
      );

      expect(estimate.units, 200000);
    });
  });
}
