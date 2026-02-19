import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getAllTokenAccountsByOwner', () {
    test('auto-paginates through all pages', () async {
      var callCount = 0;

      final client = MockClient((request) async {
        callCount++;
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getTokenAccountsByOwnerV2');
        final params = body['params'] as Map<String, Object?>;

        if (callCount == 1) {
          // First page: no cursor was sent
          expect(params.containsKey('after'), isFalse);
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 1,
              'result': {
                'accounts': [
                  {
                    'pubkey': 'tokenAcct1',
                    'account': {'lamports': 2039280},
                  },
                  {
                    'pubkey': 'tokenAcct2',
                    'account': {'lamports': 2039280},
                  },
                ],
                'cursor': 'token-next',
              },
            }),
            200,
          );
        } else {
          // Second page: cursor from previous response
          expect(params['after'], 'token-next');
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 2,
              'result': {
                'accounts': [
                  {
                    'pubkey': 'tokenAcct3',
                    'account': {'lamports': 2039280},
                  },
                ],
              },
            }),
            200,
          );
        }
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final accounts = await helius.rpcV2.getAllTokenAccountsByOwner(
        GetTokenAccountsByOwnerV2Request(ownerAddress: 'owner1'),
      );

      expect(callCount, 2);
      expect(accounts, hasLength(3));
      expect(accounts[0].pubkey, 'tokenAcct1');
      expect(accounts[1].pubkey, 'tokenAcct2');
      expect(accounts[2].pubkey, 'tokenAcct3');
    });

    test('returns single page when no cursor', () async {
      var callCount = 0;

      final client = MockClient((request) async {
        callCount++;
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'accounts': [
                {
                  'pubkey': 'tokenAcct1',
                  'account': {'lamports': 2039280},
                },
              ],
            },
          }),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final accounts = await helius.rpcV2.getAllTokenAccountsByOwner(
        GetTokenAccountsByOwnerV2Request(ownerAddress: 'owner1'),
      );

      expect(callCount, 1);
      expect(accounts, hasLength(1));
      expect(accounts[0].pubkey, 'tokenAcct1');
    });
  });
}
