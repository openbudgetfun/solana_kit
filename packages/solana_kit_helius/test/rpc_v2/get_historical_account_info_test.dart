import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getHistoricalAccountInfo', () {
    test('sends positional params and parses an encoded account', () async {
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
                'lamports': 2039280,
                'owner': 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                'data': ['base64data', 'base64'],
                'executable': false,
                'rentEpoch': 361,
                'space': 165,
                'lastUpdatedAt': {
                  'slot': 445000000,
                  'transactionIndex': 10,
                },
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

      final response = await helius.rpcV2.getHistoricalAccountInfo(
        const GetHistoricalAccountInfoRequest(
          address: 'account-1',
          query: HistoricalAccountQuery(slot: 445000000, transactionIndex: 10),
          config: GetHistoricalAccountInfoConfig(encoding: 'jsonParsed'),
        ),
      );

      expect(capturedBody['method'], 'getHistoricalAccountInfo');
      // Positional params: an omitted query or config would serialize as a
      // null slot, so the empty object stands for "latest indexed slot".
      expect(capturedBody['params'], [
        'account-1',
        {'slot': 445000000, 'transactionIndex': 10},
        {'encoding': 'jsonParsed'},
      ]);
      expect(response.slot, 445001000);
      expect(response.value, isNotNull);
      expect(response.value!.lamports, 2039280);
      expect(
        response.value!.owner,
        'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
      );
      expect(response.value!.data, ['base64data', 'base64']);
      expect(response.value!.lastUpdatedSlot, 445000000);
      expect(response.value!.lastUpdatedTransactionIndex, 10);
    });

    test('an omitted query and config serialize as empty objects', () async {
      late Map<String, Object?> capturedBody;
      final client = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'context': {'slot': 445001000},
              'value': null,
            },
          }),
          200,
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final response = await helius.rpcV2.getHistoricalAccountInfo(
        const GetHistoricalAccountInfoRequest(address: 'account-1'),
      );

      expect(capturedBody['params'], [
        'account-1',
        <String, Object?>{},
        <String, Object?>{},
      ]);
      // value is null: the account did not exist at that position. Absence
      // is not an error.
      expect(response.value, isNull);
    });

    test('a null transactionIndex marks a non-transaction write', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'context': {'slot': 445001000},
              'value': {
                'lamports': 1,
                'owner': 'owner-1',
                'data': ['data', 'base64+zstd'],
                'executable': false,
                'rentEpoch': 0,
                'space': 0,
                'lastUpdatedAt': <String, Object?>{
                  'slot': 445000123,
                  'transactionIndex': null,
                },
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

      final response = await helius.rpcV2.getHistoricalAccountInfo(
        const GetHistoricalAccountInfoRequest(address: 'account-1'),
      );

      expect(response.value!.lastUpdatedSlot, 445000123);
      expect(
        response.value!.lastUpdatedTransactionIndex,
        isNull,
        reason: 'epoch rewards and other non-transaction writes have no index',
      );
    });
  });
}
