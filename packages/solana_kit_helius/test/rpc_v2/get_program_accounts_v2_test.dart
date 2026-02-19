import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getProgramAccountsV2', () {
    test('sends correct request and deserializes response', () async {
      final mockResponse = {
        'accounts': [
          {
            'pubkey': 'pk1',
            'account': {
              'data': ['base64data', 'base64'],
              'executable': false,
              'lamports': 1000000,
              'owner': 'programId1',
              'rentEpoch': 100,
            },
          },
          {
            'pubkey': 'pk2',
            'account': {
              'data': ['base64data2', 'base64'],
              'executable': false,
              'lamports': 2000000,
              'owner': 'programId1',
              'rentEpoch': 100,
            },
          },
        ],
        'cursor': 'next',
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['jsonrpc'], '2.0');
        expect(body['method'], 'getProgramAccountsV2');
        final params = body['params']! as Map<String, Object?>;
        expect(params['programAddress'], 'program1');
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.rpcV2.getProgramAccountsV2(
        const GetProgramAccountsV2Request(programAddress: 'program1'),
      );

      expect(result.accounts, hasLength(2));
      expect(result.accounts[0].pubkey, 'pk1');
      expect(result.accounts[1].pubkey, 'pk2');
      expect(result.cursor, 'next');
    });

    test('handles response without cursor', () async {
      final mockResponse = {
        'accounts': [
          {
            'pubkey': 'pk1',
            'account': {'lamports': 1000},
          },
        ],
      };

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(
        const HeliusConfig(apiKey: 'test'),
        client: client,
      );
      final result = await helius.rpcV2.getProgramAccountsV2(
        const GetProgramAccountsV2Request(programAddress: 'program1'),
      );

      expect(result.accounts, hasLength(1));
      expect(result.cursor, isNull);
    });
  });
}
