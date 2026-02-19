import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('StakingClient.createUnstakeTransaction', () {
    test('sends POST to /v0/staking/unstake with correct body', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/staking/unstake');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['from'], 'owner-address');
        expect(body['stakeAccount'], 'stake-account-1');
        return http.Response(
          jsonEncode(<String, Object?>{'transaction': 'base64tx-unstake'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.staking.createUnstakeTransaction(
        const CreateUnstakeTransactionRequest(
          from: 'owner-address',
          stakeAccount: 'stake-account-1',
        ),
      );

      expect(result.transaction, 'base64tx-unstake');
    });

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Bad Request', 400);
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.staking.createUnstakeTransaction(
          const CreateUnstakeTransactionRequest(
            from: 'owner-address',
            stakeAccount: 'stake-account-1',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
