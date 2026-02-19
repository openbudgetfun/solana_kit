import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('StakingClient.getWithdrawableAmount', () {
    test(
      'sends GET to /v0/staking/withdrawable/{stakeAccount} and returns amount',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/staking/withdrawable/stake-account-1');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<String, Object?>{'amount': 500000}),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.staking.getWithdrawableAmount(
          GetWithdrawableAmountRequest(stakeAccount: 'stake-account-1'),
        );

        expect(result.amount, 500000);
      },
    );

    test('throws on HTTP error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      expect(
        () => helius.staking.getWithdrawableAmount(
          GetWithdrawableAmountRequest(stakeAccount: 'bad-account'),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
