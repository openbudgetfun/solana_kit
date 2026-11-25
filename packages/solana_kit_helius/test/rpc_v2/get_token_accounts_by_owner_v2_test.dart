import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getTokenAccountsByOwnerV2', () {
    test('sends correct request and deserializes response', () async {
      final mockResponse = {
        'accounts': [
          {
            'pubkey': 'tokenAcct1',
            'account': {
              'data': ['base64data', 'base64'],
              'executable': false,
              'lamports': 2039280,
              'owner': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
              'rentEpoch': 361,
            },
          },
          {
            'pubkey': 'tokenAcct2',
            'account': {
              'data': ['base64data2', 'base64'],
              'executable': false,
              'lamports': 2039280,
              'owner': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
              'rentEpoch': 361,
            },
          },
        ],
        'cursor': 'token-cursor-next',
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['jsonrpc'], '2.0');
        expect(body['method'], 'getTokenAccountsByOwnerV2');
        final params = body['params']! as Map<String, Object?>;
        expect(params['ownerAddress'], 'owner1');
        expect(params['mint'], 'mintAddr');
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.rpcV2.getTokenAccountsByOwnerV2(
        const GetTokenAccountsByOwnerV2Request(
          ownerAddress: 'owner1',
          mint: 'mintAddr',
        ),
      );

      expect(result.accounts, hasLength(2));
      expect(result.accounts[0].pubkey, 'tokenAcct1');
      expect(result.accounts[1].pubkey, 'tokenAcct2');
      expect(result.cursor, 'token-cursor-next');
    });

    test('handles response without cursor', () async {
      final mockResponse = {
        'accounts': [
          {
            'pubkey': 'tokenAcct1',
            'account': {'lamports': 2039280},
          },
        ],
      };

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.rpcV2.getTokenAccountsByOwnerV2(
        const GetTokenAccountsByOwnerV2Request(ownerAddress: 'owner1'),
      );

      expect(result.accounts, hasLength(1));
      expect(result.cursor, isNull);
    });
    test('parses the withContext page shape', () async {
      // Upstream v4.0.0 #409: with withContext the page (accounts,
      // paginationKey, totalResults) sits under value next to context.
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final params = body['params']! as Map<String, Object?>;
        expect(params['withContext'], true);
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'context': {'slot': 12345, 'apiVersion': '2.1.0'},
              'value': {
                'accounts': [
                  {
                    'pubkey': 'tokenAcct1',
                    'account': {
                      'data': ['base64data', 'base64'],
                      'executable': false,
                      'lamports': 2039280,
                      'owner': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                      'rentEpoch': 361,
                    },
                  },
                ],
                'paginationKey': 'page-two',
                'totalResults': 42,
              },
            },
          }),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);

      final response = await helius.rpcV2.getTokenAccountsByOwnerV2(
        const GetTokenAccountsByOwnerV2Request(
          ownerAddress: 'owner1',
          withContext: true,
        ),
      );

      expect(response.slot, 12345);
      expect(response.accounts, hasLength(1));
      expect(response.accounts.first.pubkey, 'tokenAcct1');
      expect(response.cursor, 'page-two');
      expect(response.totalResults, 42);
    });

    test('parses the default value-array shape', () async {
      // Upstream v4.0.0 #409: by default value IS the accounts array, with
      // paginationKey next to it.
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(
          (body['params']! as Map<String, Object?>)['withContext'],
          isNull,
        );
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'value': [
                {
                  'pubkey': 'tokenAcct1',
                  'account': {
                    'data': ['base64data', 'base64'],
                    'executable': false,
                    'lamports': 2039280,
                    'owner': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                    'rentEpoch': 361,
                  },
                },
              ],
              'paginationKey': null,
            },
          }),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);

      final response = await helius.rpcV2.getTokenAccountsByOwnerV2(
        const GetTokenAccountsByOwnerV2Request(ownerAddress: 'owner1'),
      );

      expect(response.slot, isNull);
      expect(response.accounts, hasLength(1));
      expect(response.cursor, isNull);
    });
  });
}
