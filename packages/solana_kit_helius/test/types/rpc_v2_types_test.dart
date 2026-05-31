import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('RPC v2 pagination types', () {
    test('program accounts request and response round-trip JSON', () {
      const request = GetProgramAccountsV2Request(
        programAddress: 'program-1',
        filters: [
          {'memcmp': {'offset': 0, 'bytes': 'abc'}},
        ],
        encoding: 'base64',
        dataSlice: 32,
        after: 'cursor-1',
        limit: 10,
      );
      final requestJson = request.toJson();
      final parsedRequest = GetProgramAccountsV2Request.fromJson(requestJson);

      expect(parsedRequest.programAddress, 'program-1');
      expect(parsedRequest.filters, request.filters);
      expect(parsedRequest.encoding, 'base64');
      expect(parsedRequest.dataSlice, 32);
      expect(parsedRequest.after, 'cursor-1');
      expect(parsedRequest.limit, 10);
      expect(parsedRequest.toJson(), requestJson);

      final responseJson = {
        'accounts': [
          {
            'pubkey': 'account-1',
            'account': {'lamports': 1},
          },
        ],
        'cursor': 'next',
      };
      final response = GetProgramAccountsV2Response.fromJson(responseJson);

      expect(response.accounts.single.pubkey, 'account-1');
      expect(response.accounts.single.account, {'lamports': 1});
      expect(response.cursor, 'next');
      expect(response.toJson(), responseJson);
    });

    test('token account request and response round-trip JSON', () {
      const request = GetTokenAccountsByOwnerV2Request(
        ownerAddress: 'owner-1',
        mint: 'mint-1',
        programId: 'token-program',
        encoding: 'jsonParsed',
        after: 'cursor-1',
        limit: 25,
      );
      final requestJson = request.toJson();
      final parsedRequest = GetTokenAccountsByOwnerV2Request.fromJson(requestJson);

      expect(parsedRequest.ownerAddress, 'owner-1');
      expect(parsedRequest.mint, 'mint-1');
      expect(parsedRequest.programId, 'token-program');
      expect(parsedRequest.encoding, 'jsonParsed');
      expect(parsedRequest.after, 'cursor-1');
      expect(parsedRequest.limit, 25);
      expect(parsedRequest.toJson(), requestJson);

      final responseJson = {
        'accounts': [
          {
            'pubkey': 'token-account-1',
            'account': {'mint': 'mint-1'},
          },
        ],
        'cursor': 'next',
      };
      final response = GetTokenAccountsByOwnerV2Response.fromJson(responseJson);

      expect(response.accounts.single.pubkey, 'token-account-1');
      expect(response.accounts.single.account, {'mint': 'mint-1'});
      expect(response.cursor, 'next');
      expect(response.toJson(), responseJson);
    });
  });

  group('RPC v2 transaction and transfer types', () {
    test('transaction request and response include optional fields', () {
      const request = GetTransactionsForAddressRequest(
        address: 'address-1',
        before: 'sig-before',
        until: 'sig-until',
        limit: 5,
        commitment: CommitmentLevel.confirmed,
      );
      final requestJson = request.toJson();
      final parsedRequest = GetTransactionsForAddressRequest.fromJson(requestJson);

      expect(parsedRequest.address, 'address-1');
      expect(parsedRequest.before, 'sig-before');
      expect(parsedRequest.until, 'sig-until');
      expect(parsedRequest.limit, 5);
      expect(parsedRequest.commitment, CommitmentLevel.confirmed);
      expect(parsedRequest.toJson(), requestJson);

      final responseJson = {
        'transactions': [
          {
            'signature': 'sig-1',
            'slot': 123,
            'blockTime': 456,
            'err': {'InstructionError': [0, 'Custom']},
            'memo': 'memo text',
          },
        ],
      };
      final response = GetTransactionsForAddressResponse.fromJson(responseJson);

      expect(response.transactions.single.signature, 'sig-1');
      expect(response.transactions.single.err, {'InstructionError': [0, 'Custom']});
      expect(response.toJson(), responseJson);
    });

    test('transfer request, config, response, and transfer record serialize JSON', () {
      const config = GetTransfersByAddressConfig(
        withAddress: 'counterparty',
        direction: 'inbound',
        mint: 'mint-1',
        solMode: 'exclude',
        filters: {'type': 'transfer'},
        limit: 50,
        paginationToken: 'page-1',
        commitment: CommitmentLevel.finalized,
        sortOrder: 'asc',
      );
      const request = GetTransfersByAddressRequest(address: 'owner-1', config: config);
      final configJson = {
        'with': 'counterparty',
        'direction': 'inbound',
        'mint': 'mint-1',
        'solMode': 'exclude',
        'filters': {'type': 'transfer'},
        'limit': 50,
        'paginationToken': 'page-1',
        'commitment': 'finalized',
        'sortOrder': 'asc',
      };

      expect(config.toJson(), configJson);
      expect(request.toJson(), ['owner-1', configJson]);
      expect(const GetTransfersByAddressRequest(address: 'owner-1').toJson(), ['owner-1']);

      final transferJson = addressTransferJson();
      final responseJson = {
        'data': [transferJson],
        'paginationToken': 'next-page',
      };
      final response = GetTransfersByAddressResponse.fromJson(responseJson);

      expect(response.data.single.signature, 'sig-transfer');
      expect(response.data.single.fromTokenAccount, 'from-token');
      expect(response.paginationToken, 'next-page');
      expect(response.toJson(), responseJson);
    });
  });
}

Map<String, Object?> addressTransferJson() => {
  'signature': 'sig-transfer',
  'slot': 42,
  'blockTime': 1700000000,
  'type': 'spl',
  'fromUserAccount': 'from-user',
  'toUserAccount': 'to-user',
  'fromTokenAccount': 'from-token',
  'toTokenAccount': 'to-token',
  'mint': 'mint-1',
  'amount': '1000',
  'feeAmount': '1',
  'feeAccount': 'fee-account',
  'decimals': 6,
  'uiAmount': '0.001',
  'feeUiAmount': '0.000001',
  'confirmationStatus': 'finalized',
  'transactionIdx': 0,
  'instructionIdx': 1,
  'innerInstructionIdx': 2,
};
