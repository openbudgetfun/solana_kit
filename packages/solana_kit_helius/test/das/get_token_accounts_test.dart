import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('DasClient.getTokenAccounts', () {
    test(
      'sends correct JSON-RPC request and deserializes TokenAccountList',
      () async {
        final mockTokenAccountList = <String, Object?>{
          'total': 2,
          'limit': 10,
          'token_accounts': <Object?>[
            <String, Object?>{
              'address': 'acct-1',
              'mint': 'mint-a',
              'owner': 'owner-1',
              'amount': 1000,
              'delegated_amount': 0,
              'frozen': false,
            },
            <String, Object?>{
              'address': 'acct-2',
              'mint': 'mint-b',
              'owner': 'owner-1',
              'amount': 500,
            },
          ],
        };

        final client = MockClient((request) async {
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, Object?>;
          expect(body['method'], 'getTokenAccounts');
          expect(body['jsonrpc'], '2.0');
          final params = body['params'] as Map<String, Object?>;
          expect(params['owner'], 'owner-1');
          return http.Response(
            jsonEncode(<String, Object?>{
              'jsonrpc': '2.0',
              'id': 1,
              'result': mockTokenAccountList,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final result = await helius.das.getTokenAccounts(
          GetTokenAccountsRequest(owner: 'owner-1'),
        );

        expect(result.total, 2);
        expect(result.limit, 10);
        expect(result.tokenAccounts.length, 2);
        expect(result.tokenAccounts[0].address, 'acct-1');
        expect(result.tokenAccounts[0].mint, 'mint-a');
        expect(result.tokenAccounts[0].owner, 'owner-1');
        expect(result.tokenAccounts[0].amount, 1000);
        expect(result.tokenAccounts[0].delegatedAmount, 0);
        expect(result.tokenAccounts[0].frozen, false);
        expect(result.tokenAccounts[1].address, 'acct-2');
        expect(result.tokenAccounts[1].amount, 500);
      },
    );

    test('filters by mint', () async {
      final mockTokenAccountList = <String, Object?>{
        'total': 1,
        'limit': 10,
        'token_accounts': <Object?>[
          <String, Object?>{
            'address': 'acct-3',
            'mint': 'mint-x',
            'owner': 'owner-2',
            'amount': 100,
          },
        ],
      };

      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final params = body['params'] as Map<String, Object?>;
        expect(params['mint'], 'mint-x');
        return http.Response(
          jsonEncode(<String, Object?>{
            'jsonrpc': '2.0',
            'id': 1,
            'result': mockTokenAccountList,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final result = await helius.das.getTokenAccounts(
        GetTokenAccountsRequest(mint: 'mint-x'),
      );

      expect(result.total, 1);
      expect(result.tokenAccounts[0].mint, 'mint-x');
    });

    test('throws on RPC error', () async {
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
        () =>
            helius.das.getTokenAccounts(GetTokenAccountsRequest(owner: 'bad')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
