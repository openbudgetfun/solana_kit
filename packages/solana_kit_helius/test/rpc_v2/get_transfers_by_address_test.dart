import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RpcV2Client.getTransfersByAddress', () {
    test('sends tuple params and deserializes transfers', () async {
      final client = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, Object?>;
        expect(body['method'], 'getTransfersByAddress');
        expect(body['params'], [
          'addr1',
          {'direction': 'out', 'limit': 2, 'commitment': 'confirmed'},
        ]);
        return http.Response(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'result': {
              'data': [
                {
                  'signature': 'sig1',
                  'slot': 100,
                  'blockTime': 1700000000,
                  'type': 'transfer',
                  'fromUserAccount': 'addr1',
                  'toUserAccount': 'addr2',
                  'mint': 'So11111111111111111111111111111111111111112',
                  'amount': '1000000',
                  'decimals': 9,
                  'uiAmount': '0.001',
                  'confirmationStatus': 'confirmed',
                  'transactionIdx': 0,
                  'instructionIdx': 1,
                  'innerInstructionIdx': 0,
                },
              ],
              'paginationToken': 'next',
            },
          }),
          200,
        );
      });

      final helius = createHelius(HeliusConfig(apiKey: 'test'), client: client);
      final result = await helius.rpcV2.getTransfersByAddress(
        const GetTransfersByAddressRequest(
          address: 'addr1',
          config: GetTransfersByAddressConfig(
            direction: 'out',
            limit: 2,
            commitment: CommitmentLevel.confirmed,
          ),
        ),
      );

      expect(result.paginationToken, 'next');
      expect(result.data.single.signature, 'sig1');
      expect(result.data.single.uiAmount, '0.001');
    });
  });
}
