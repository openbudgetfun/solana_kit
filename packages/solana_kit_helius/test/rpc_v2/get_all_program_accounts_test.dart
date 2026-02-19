import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getAllProgramAccounts', () {
    test('auto-paginates through all pages', () async {
      var callCount = 0;

      final client = MockClient((request) async {
        callCount++;
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getProgramAccountsV2');
        final params = body['params']! as Map<String, Object?>;

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
                    'pubkey': 'pk1',
                    'account': {'lamports': 1000},
                  },
                  {
                    'pubkey': 'pk2',
                    'account': {'lamports': 2000},
                  },
                ],
                'cursor': 'next-cursor',
              },
            }),
            200,
          );
        } else {
          // Second page: cursor from previous response
          expect(params['after'], 'next-cursor');
          return http.Response(
            jsonEncode({
              'jsonrpc': '2.0',
              'id': 2,
              'result': {
                'accounts': [
                  {
                    'pubkey': 'pk3',
                    'account': {'lamports': 3000},
                  },
                ],
              },
            }),
            200,
          );
        }
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final accounts = await helius.rpcV2.getAllProgramAccounts(
        const GetProgramAccountsV2Request(programAddress: 'program1'),
      );

      expect(callCount, 2);
      expect(accounts, hasLength(3));
      expect(accounts[0].pubkey, 'pk1');
      expect(accounts[1].pubkey, 'pk2');
      expect(accounts[2].pubkey, 'pk3');
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
                  'pubkey': 'pk1',
                  'account': {'lamports': 1000},
                },
              ],
            },
          }),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final accounts = await helius.rpcV2.getAllProgramAccounts(
        const GetProgramAccountsV2Request(programAddress: 'program1'),
      );

      expect(callCount, 1);
      expect(accounts, hasLength(1));
      expect(accounts[0].pubkey, 'pk1');
    });
  });
}
