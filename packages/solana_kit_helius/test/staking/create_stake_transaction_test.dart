import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('StakingClient.createStakeTransaction', () {
    test('sends POST to /v0/staking/stake with correct body', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/staking/stake');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['from'], 'owner-address');
        expect(body['amount'], 1000000);
        return http.Response(
          jsonEncode(<String, Object?>{'transaction': 'base64tx'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.staking.createStakeTransaction(
        CreateStakeTransactionRequest(from: 'owner-address', amount: 1000000),
      );

      expect(result.transaction, 'base64tx');
    });

    test('includes validatorVote when provided', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['from'], 'owner-address');
        expect(body['amount'], 500000);
        expect(body['validatorVote'], 'validator1');
        return http.Response(
          jsonEncode(<String, Object?>{'transaction': 'base64tx-vote'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.staking.createStakeTransaction(
        CreateStakeTransactionRequest(
          from: 'owner-address',
          amount: 500000,
          validatorVote: 'validator1',
        ),
      );

      expect(result.transaction, 'base64tx-vote');
    });
  });
}
