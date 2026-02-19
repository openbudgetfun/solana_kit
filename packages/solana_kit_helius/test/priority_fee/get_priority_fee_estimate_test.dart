import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('PriorityFeeClient.getPriorityFeeEstimate', () {
    test('sends correct request and deserializes response', () async {
      final mockResponse = {
        'priorityFeeEstimate': 1000.0,
        'priorityFeeLevels': {
          'min': 100.0,
          'low': 500.0,
          'medium': 1000.0,
          'high': 5000.0,
          'veryHigh': 10000.0,
          'unsafeMax': 50000.0,
        },
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['jsonrpc'], '2.0');
        expect(body['method'], 'getPriorityFeeEstimate');
        final params = body['params']! as Map<String, Object?>;
        expect(params['accountKeys'], ['key1']);
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.priorityFee.getPriorityFeeEstimate(
        const GetPriorityFeeEstimateRequest(accountKeys: ['key1']),
      );

      expect(result.priorityFeeEstimate, 1000.0);
      expect(result.priorityFeeLevels, isNotNull);
      expect(result.priorityFeeLevels?.min, 100.0);
      expect(result.priorityFeeLevels?.low, 500.0);
      expect(result.priorityFeeLevels?.medium, 1000.0);
      expect(result.priorityFeeLevels?.high, 5000.0);
      expect(result.priorityFeeLevels?.veryHigh, 10000.0);
      expect(result.priorityFeeLevels?.unsafeMax, 50000.0);
    });

    test('sends request with transaction and options', () async {
      final mockResponse = {'priorityFeeEstimate': 2500.0};

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getPriorityFeeEstimate');
        final params = body['params']! as Map<String, Object?>;
        expect(params['transaction'], 'base64EncodedTx');
        final options = params['options']! as Map<String, Object?>;
        expect(options['priorityLevel'], 'High');
        expect(options['includeAllPriorityFeeLevels'], true);
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.priorityFee.getPriorityFeeEstimate(
        const GetPriorityFeeEstimateRequest(
          transaction: 'base64EncodedTx',
          options: PriorityFeeOptions(
            priorityLevel: PriorityLevel.high,
            includeAllPriorityFeeLevels: true,
          ),
        ),
      );

      expect(result.priorityFeeEstimate, 2500.0);
      expect(result.priorityFeeLevels, isNull);
    });
  });
}
