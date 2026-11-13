import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getHistoricalTokenAccountsByOwner', () {
    test('sends the query and config and parses a page', () async {
      late Map<String, Object?> capturedBody;
      final client = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'context': {'slot': 445001000},
              'value': {
                'accounts': [
                  {
                    'pubkey': 'tokenAcct1',
                    'account': {
                      'lamports': 2039280,
                      'owner': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                      'data': {
                        'program': 'spl-token',
                        'parsed': <String, Object?>{
                          'type': 'account',
                          'info': <String, Object?>{},
                        },
                        'space': 165,
                      },
                      'executable': false,
                      'rentEpoch': 361,
                      'space': 165,
                      'lastUpdatedAt': {
                        'slot': 445000000,
                        'transactionIndex': null,
                      },
                    },
                  },
                  {
                    'pubkey': 'tokenAcct2',
                    'account': {
                      'lamports': 100,
                      'owner': 'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
                      'data': ['rawdata', 'base64'],
                      'executable': false,
                      'rentEpoch': 361,
                      'space': 165,
                      'lastUpdatedAt': {
                        'slot': 445000000,
                        'transactionIndex': 3,
                      },
                    },
                  },
                ],
                'paginationKey': 'next-page-key',
              },
            },
          }),
          200,
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final response = await helius.rpcV2.getHistoricalTokenAccountsByOwner(
        const GetHistoricalTokenAccountsByOwnerRequest(
          ownerAddress: 'owner-1',
          query: HistoricalAccountQuery(slot: 445000000),
          mint: 'mint-1',
          encoding: 'jsonParsed',
          limit: 100,
          paginationKey: 'page-one',
        ),
      );

      expect(capturedBody['method'], 'getHistoricalTokenAccountsByOwner');
      expect(capturedBody['params'], [
        'owner-1',
        {'slot': 445000000},
        {
          'mint': 'mint-1',
          'encoding': 'jsonParsed',
          'limit': 100,
          'paginationKey': 'page-one',
        },
      ]);
      expect(response.slot, 445001000);
      expect(response.accounts, hasLength(2));
      // jsonParsed data falls back to the encoded pair when parsing fails;
      // both shapes surface as raw data the caller branches on.
      expect(
        response.accounts.first.account.data,
        isA<Map<String, Object?>>(),
        reason: 'parsed data arrives as an object',
      );
      expect(
        response.accounts.last.account.data,
        ['rawdata', 'base64'],
        reason: 'unparseable accounts fall back to [data, "base64"]',
      );
      expect(response.paginationKey, 'next-page-key');
    });

    test('a page without a cursor ends the scan', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'context': {'slot': 445001000},
              'value': <String, Object?>{
                'accounts': <Object?>[],
                'paginationKey': null,
              },
            },
          }),
          200,
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final response = await helius.rpcV2.getHistoricalTokenAccountsByOwner(
        const GetHistoricalTokenAccountsByOwnerRequest(
          ownerAddress: 'owner-1',
          query: HistoricalAccountQuery(slot: 445000000),
        ),
      );

      expect(response.accounts, isEmpty);
      expect(response.paginationKey, isNull);
    });
  });
}
