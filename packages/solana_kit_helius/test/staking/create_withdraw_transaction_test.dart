import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('StakingClient.createWithdrawTransaction', () {
    test('sends POST to /v0/staking/withdraw with correct body', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/v0/staking/withdraw');
        expect(request.url.queryParameters['api-key'], isNotEmpty);
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['from'], 'owner-address');
        expect(body['stakeAccount'], 'stake-account-1');
        return http.Response(
          jsonEncode(<String, Object?>{'transaction': 'base64tx-withdraw'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.staking.createWithdrawTransaction(
        CreateWithdrawTransactionRequest(
          from: 'owner-address',
          stakeAccount: 'stake-account-1',
        ),
      );

      expect(result.transaction, 'base64tx-withdraw');
    });

    test('includes amount when provided', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['from'], 'owner-address');
        expect(body['stakeAccount'], 'stake-account-1');
        expect(body['amount'], 250000);
        return http.Response(
          jsonEncode(<String, Object?>{'transaction': 'base64tx-partial'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.staking.createWithdrawTransaction(
        CreateWithdrawTransactionRequest(
          from: 'owner-address',
          stakeAccount: 'stake-account-1',
          amount: 250000,
        ),
      );

      expect(result.transaction, 'base64tx-partial');
    });
  });
}
