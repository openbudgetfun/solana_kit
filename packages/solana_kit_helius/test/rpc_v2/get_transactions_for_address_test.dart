import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getTransactionsForAddress', () {
    test('sends correct request and deserializes response', () async {
      final mockResponse = {
        'data': [
          {
            'signature': 'sig1',
            'slot': 100,
            'transactionIndex': 2,
            'blockTime': 1700000000,
            'confirmationStatus': 'confirmed',
          },
          {'signature': 'sig2', 'slot': 101},
        ],
        'paginationToken': 'next-page',
      };

      final client = MockClient((request) async {
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['jsonrpc'], '2.0');
        expect(body['method'], 'getTransactionsForAddress');
        final params = body['params']! as Map<String, Object?>;
        expect(params['address'], 'addr1');
        return http.Response(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': mockResponse}),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.rpcV2.getTransactionsForAddress(
        const GetTransactionsForAddressRequest(address: 'addr1'),
      );

      expect(result.data, hasLength(2));
      expect(result.paginationToken, 'next-page');
      final first = result.data[0] as TransactionForAddress;
      expect(first.signature, 'sig1');
      expect(first.slot, 100);
      expect(first.transactionIndex, 2);
      expect(first.blockTime, 1700000000);
      expect(first.confirmationStatus, 'confirmed');
      expect(result.transactions, hasLength(2));
    });

    test('sends the full filter surface including tokenTransfer', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        final params = body['params']! as Map<String, Object?>;
        expect(params['address'], 'addr1');
        expect(params['transactionDetails'], 'full');
        expect(params['limit'], 10);
        expect(params['commitment'], 'confirmed');
        expect(params['sortOrder'], 'asc');
        expect(params['paginationToken'], 'page-1');
        expect(params['filters'], {
          'status': 'succeeded',
          'tokenAccounts': 'balanceChanged',
          'tokenTransfer': {
            'with': 'counterparty',
            'direction': 'in',
            'mint': 'mint-1',
            'amount': {'gte': 100, 'lte': 200},
          },
          'slot': {'gte': 1, 'lt': 10},
          'blockTime': {'gt': 100},
          'signature': {'lte': 'zzz'},
        });
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'data': [
                {
                  'slot': 100,
                  'transactionIndex': 1,
                  'transaction': {
                    'signatures': ['sig'],
                  },
                  'meta': {'fee': 5000},
                  'blockTime': 1700000000,
                },
              ],
              'paginationToken': null,
            },
          }),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.rpcV2.getTransactionsForAddress(
        const GetTransactionsForAddressRequest(
          address: 'addr1',
          transactionDetails: 'full',
          limit: 10,
          commitment: CommitmentLevel.confirmed,
          paginationToken: 'page-1',
          sortOrder: 'asc',
          filters: GetTransactionsForAddressFilters(
            status: 'succeeded',
            tokenAccounts: 'balanceChanged',
            tokenTransfer: TokenTransferFilter(
              withAddress: 'counterparty',
              direction: 'in',
              mint: 'mint-1',
              amount: TransferComparisonFilter(gte: 100, lte: 200),
            ),
            slot: SlotFilter(gte: 1, lt: 10),
            blockTime: BlockTimeFilter(gt: 100),
            signature: SignatureFilter(lte: 'zzz'),
          ),
        ),
      );

      expect(result.data, hasLength(1));
      final full = result.data.single as TransactionForAddressFull;
      expect(full.slot, 100);
      expect(full.transactionIndex, 1);
      expect(full.meta, {'fee': 5000});
      expect(result.transactions, isEmpty);
    });

    test('accepts the legacy transactions response shape', () async {
      final client = MockClient(
        (_) async => http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'transactions': [
                {'signature': 'sig1', 'slot': 100},
              ],
            },
          }),
          200,
        ),
      );

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.rpcV2.getTransactionsForAddress(
        const GetTransactionsForAddressRequest(address: 'addr1'),
      );

      expect(result.transactions.single.signature, 'sig1');
    });
  });
}
