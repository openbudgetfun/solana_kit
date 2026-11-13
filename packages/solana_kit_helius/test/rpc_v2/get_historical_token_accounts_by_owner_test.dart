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
    group('serialization round-trips', () {
      test('historical query and config round-trip every field', () {
        const query = HistoricalAccountQuery(
          slot: 445000000,
          transactionIndex: 10,
        );
        final queryJson = query.toJson();
        expect(queryJson, {'slot': 445000000, 'transactionIndex': 10});
        expect(
          HistoricalAccountQuery.fromJson(queryJson).toJson(),
          queryJson,
        );
        // An empty query reads the latest indexed slot.
        expect(
          HistoricalAccountQuery.fromJson(<String, Object?>{}).toJson(),
          isEmpty,
        );

        const config = GetHistoricalAccountInfoConfig(
          encoding: 'base64+zstd',
          dataSliceOffset: 8,
          dataSliceLength: 32,
          commitment: 'confirmed',
          minContextSlot: 444960000,
        );
        final configJson = config.toJson();
        expect(configJson, {
          'encoding': 'base64+zstd',
          'dataSlice': {'offset': 8, 'length': 32},
          'commitment': 'confirmed',
          'minContextSlot': 444960000,
        });
        final decoded = GetHistoricalAccountInfoConfig.fromJson(configJson);
        expect(decoded.encoding, 'base64+zstd');
        expect(decoded.dataSliceOffset, 8);
        expect(decoded.dataSliceLength, 32);
        expect(decoded.commitment, 'confirmed');
        expect(decoded.minContextSlot, 444960000);
        // A data slice with only an offset still serializes the pair.
        expect(
          const GetHistoricalAccountInfoConfig(
            dataSliceOffset: 4,
          ).toJson(),
          {
            'dataSlice': {'offset': 4},
          },
        );
      });

      test('account info request and response round-trip', () {
        const request = GetHistoricalAccountInfoRequest(
          address: 'account-1',
          query: HistoricalAccountQuery(slot: 445000000),
          config: GetHistoricalAccountInfoConfig(encoding: 'jsonParsed'),
        );
        final decodedRequest = GetHistoricalAccountInfoRequest.fromJson({
          'address': 'account-1',
          'query': {'slot': 445000000},
          'config': {'encoding': 'jsonParsed'},
        });
        expect(decodedRequest.address, 'account-1');
        expect(decodedRequest.query!.slot, 445000000);
        expect(decodedRequest.query!.transactionIndex, isNull);
        expect(decodedRequest.config!.encoding, 'jsonParsed');
        expect(decodedRequest.toJson(), request.toJson());

        const account = HistoricalAccount(
          lamports: 2039280,
          owner: 'owner-1',
          data: ['data', 'base64'],
          executable: false,
          rentEpoch: 361,
          space: 165,
          lastUpdatedSlot: 445000000,
          lastUpdatedTransactionIndex: null,
        );
        const response = GetHistoricalAccountInfoResponse(
          slot: 445001000,
          value: account,
        );
        final responseJson = response.toJson();
        expect(responseJson, {
          'context': {'slot': 445001000},
          'value': account.toJson(),
        });
        final decodedResponse = GetHistoricalAccountInfoResponse.fromJson(
          responseJson,
        );
        expect(decodedResponse.slot, 445001000);
        expect(decodedResponse.value!.toJson(), account.toJson());
        // The null-value response serializes as the wire's null.
        expect(
          const GetHistoricalAccountInfoResponse(slot: 1).toJson()['value'],
          isNull,
        );
      });

      test('token accounts request and response round-trip', () {
        const request = GetHistoricalTokenAccountsByOwnerRequest(
          ownerAddress: 'owner-1',
          query: HistoricalAccountQuery(slot: 445000000, transactionIndex: 3),
          programId: 'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
          encoding: 'base64',
          dataSliceOffset: 0,
          dataSliceLength: 165,
          commitment: 'finalized',
          minContextSlot: 444960000,
          limit: 100,
          paginationKey: 'page-one',
        );
        final decodedRequest =
            GetHistoricalTokenAccountsByOwnerRequest.fromJson({
              'ownerAddress': 'owner-1',
              'query': {'slot': 445000000, 'transactionIndex': 3},
              'config': {
                'programId': 'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
                'encoding': 'base64',
                'dataSlice': {'offset': 0, 'length': 165},
                'commitment': 'finalized',
                'minContextSlot': 444960000,
                'limit': 100,
                'paginationKey': 'page-one',
              },
            });
        expect(decodedRequest.ownerAddress, 'owner-1');
        expect(decodedRequest.query!.transactionIndex, 3);
        expect(
          decodedRequest.programId,
          'TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb',
        );
        expect(decodedRequest.encoding, 'base64');
        expect(decodedRequest.dataSliceOffset, 0);
        expect(decodedRequest.dataSliceLength, 165);
        expect(decodedRequest.commitment, 'finalized');
        expect(decodedRequest.minContextSlot, 444960000);
        expect(decodedRequest.limit, 100);
        expect(decodedRequest.paginationKey, 'page-one');
        expect(decodedRequest.toJson(), request.toJson());
        // An omitted query serializes as the empty object the server expects.
        expect(
          const GetHistoricalTokenAccountsByOwnerRequest(
            ownerAddress: 'owner-1',
          ).toJson()[1],
          <String, Object?>{},
        );

        const keyed = HistoricalKeyedAccount(
          pubkey: 'tokenAcct1',
          account: HistoricalAccount(
            lamports: 100,
            owner: 'owner-1',
            data: <String, Object?>{'parsed': true},
            executable: false,
            rentEpoch: 361,
            space: 165,
            lastUpdatedSlot: 445000000,
            lastUpdatedTransactionIndex: 3,
          ),
        );
        const response = GetHistoricalTokenAccountsByOwnerResponse(
          slot: 445001000,
          accounts: [keyed],
          paginationKey: 'next',
        );
        final responseJson = response.toJson();
        expect(responseJson['context'], {'slot': 445001000});
        final value = responseJson['value']! as Map<String, Object?>;
        expect(value['paginationKey'], 'next');
        expect((value['accounts']! as List<Object?>).single, keyed.toJson());
        final decoded = GetHistoricalTokenAccountsByOwnerResponse.fromJson(
          responseJson,
        );
        expect(decoded.accounts.single.toJson(), keyed.toJson());
        expect(decoded.paginationKey, 'next');
      });

      test('account data that is neither parsed nor encoded throws', () {
        expect(
          () => HistoricalAccount.fromJson({
            'lamports': 1,
            'owner': 'owner-1',
            'data': 'not-a-container',
            'executable': false,
            'rentEpoch': 0,
            'space': 0,
            'lastUpdatedAt': {'slot': 1, 'transactionIndex': null},
          }),
          throwsA(isA<FormatException>()),
        );
      });
    });
  });
}
