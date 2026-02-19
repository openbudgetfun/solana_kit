import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('StakingClient.getHeliusStakeAccounts', () {
    test(
      'sends GET to /v0/staking/accounts/{owner} and returns list',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/v0/staking/accounts/owner-address');
          expect(request.url.queryParameters['api-key'], isNotEmpty);
          return http.Response(
            jsonEncode(<Object?>[
              <String, Object?>{
                'address': 'addr',
                'lamports': 1000000,
                'state': 'active',
                'voter': 'voter1',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final accounts = await helius.staking.getHeliusStakeAccounts(
          GetHeliusStakeAccountsRequest(owner: 'owner-address'),
        );

        expect(accounts, hasLength(1));
        expect(accounts[0].address, 'addr');
        expect(accounts[0].lamports, 1000000);
        expect(accounts[0].state, 'active');
        expect(accounts[0].voter, 'voter1');
      },
    );

    test('returns empty list when no accounts', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode(<Object?>[]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final accounts = await helius.staking.getHeliusStakeAccounts(
        GetHeliusStakeAccountsRequest(owner: 'no-stakes-owner'),
      );

      expect(accounts, isEmpty);
    });
  });
}
