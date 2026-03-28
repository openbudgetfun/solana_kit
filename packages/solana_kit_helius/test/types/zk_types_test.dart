import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('zk types', () {
    expectJsonRoundTrip(
      'CompressedAccount roundtrips',
      {
        'hash': 'hash-1',
        'address': 'address-1',
        'data': {'program': 'memo'},
        'owner': 'owner-1',
        'lamports': 10,
        'leafIndex': 2,
        'tree': 'tree-1',
        'seq': 3,
      },
      CompressedAccount.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedAccountProof roundtrips',
      {
        'hash': 'hash-1',
        'root': 'root-1',
        'proof': ['a', 'b'],
        'leafIndex': 2,
        'tree': 'tree-1',
      },
      CompressedAccountProof.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedTokenAccount roundtrips',
      {
        'hash': 'hash-1',
        'owner': 'owner-1',
        'mint': 'mint-1',
        'amount': 99,
        'delegate': 'delegate-1',
        'frozen': false,
        'leafIndex': 2,
        'tree': 'tree-1',
      },
      CompressedTokenAccount.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedBalance roundtrips',
      {'amount': 10},
      CompressedBalance.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedTokenBalance roundtrips',
      {'mint': 'mint-1', 'amount': 10},
      CompressedTokenBalance.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedTokenBalanceV2 roundtrips',
      {'mint': 'mint-1', 'amount': 10, 'decimals': 6},
      CompressedTokenBalanceV2.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedSignature roundtrips',
      {'signature': 'sig-1', 'slot': 9, 'blockTime': 123456},
      CompressedSignature.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'IndexerHealth roundtrips',
      {'status': 'ok'},
      IndexerHealth.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'ValidityProof roundtrips',
      {
        'compressedProof': ['a', 'b'],
        'rootIndices': ['1', '2'],
        'leafIndices': '3,4',
      },
      ValidityProof.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'NewAddressProof roundtrips',
      {
        'address': 'address-1',
        'root': 'root-1',
        'proof': ['a', 'b'],
        'leafIndex': 1,
        'tree': 'tree-1',
      },
      NewAddressProof.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'TransactionWithCompressionInfo roundtrips',
      {
        'transaction': {'signature': 'sig-1'},
        'compressionInfo': {'compressed': true},
      },
      TransactionWithCompressionInfo.fromJson,
      (value) => value.toJson(),
    );

    for (final entry in <String, Map<String, Object?>>{
      'GetCompressedAccountRequest': {'hash': 'hash-1'},
      'GetCompressedAccountProofRequest': {'hash': 'hash-1'},
      'GetCompressedAccountsByOwnerRequest': {
        'owner': 'owner-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressedBalanceRequest': {'hash': 'hash-1'},
      'GetCompressedBalanceByOwnerRequest': {'owner': 'owner-1'},
      'GetCompressedMintTokenHoldersRequest': {
        'mint': 'mint-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressedTokenAccountBalanceRequest': {'hash': 'hash-1'},
      'GetCompressedTokenAccountsByDelegateRequest': {
        'delegate': 'delegate-1',
        'mint': 'mint-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressedTokenAccountsByOwnerRequest': {
        'owner': 'owner-1',
        'mint': 'mint-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressedTokenBalancesByOwnerRequest': {
        'owner': 'owner-1',
        'mint': 'mint-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressionSignaturesForAccountRequest': {
        'hash': 'hash-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressionSignaturesForAddressRequest': {
        'address': 'address-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressionSignaturesForOwnerRequest': {
        'owner': 'owner-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetCompressionSignaturesForTokenOwnerRequest': {
        'owner': 'owner-1',
        'mint': 'mint-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetLatestCompressionSignaturesRequest': {
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetLatestNonVotingSignaturesRequest': {
        'cursor': 'cursor-1',
        'limit': 10,
      },
      'GetMultipleCompressedAccountProofsRequest': {
        'hashes': ['hash-1', 'hash-2'],
      },
      'GetMultipleCompressedAccountsRequest': {
        'hashes': ['hash-1', 'hash-2'],
      },
      'GetMultipleNewAddressProofsRequest': {
        'addresses': ['addr-1', 'addr-2'],
      },
      'GetTransactionWithCompressionInfoRequest': {
        'signature': 'sig-1',
      },
      'GetValidityProofRequest': {
        'hashes': ['hash-1', 'hash-2'],
        'newAddresses': ['addr-1', 'addr-2'],
      },
      'GetZkSignaturesForAssetRequest': {
        'id': 'asset-1',
        'cursor': 'cursor-1',
        'limit': 10,
      },
    }.entries) {
      test('${entry.key} roundtrips', () {
        final json = entry.value;
        final actual = switch (entry.key) {
          'GetCompressedAccountRequest' =>
            GetCompressedAccountRequest.fromJson(json).toJson(),
          'GetCompressedAccountProofRequest' =>
            GetCompressedAccountProofRequest.fromJson(json).toJson(),
          'GetCompressedAccountsByOwnerRequest' =>
            GetCompressedAccountsByOwnerRequest.fromJson(json).toJson(),
          'GetCompressedBalanceRequest' =>
            GetCompressedBalanceRequest.fromJson(json).toJson(),
          'GetCompressedBalanceByOwnerRequest' =>
            GetCompressedBalanceByOwnerRequest.fromJson(json).toJson(),
          'GetCompressedMintTokenHoldersRequest' =>
            GetCompressedMintTokenHoldersRequest.fromJson(json).toJson(),
          'GetCompressedTokenAccountBalanceRequest' =>
            GetCompressedTokenAccountBalanceRequest.fromJson(json).toJson(),
          'GetCompressedTokenAccountsByDelegateRequest' =>
            GetCompressedTokenAccountsByDelegateRequest.fromJson(json).toJson(),
          'GetCompressedTokenAccountsByOwnerRequest' =>
            GetCompressedTokenAccountsByOwnerRequest.fromJson(json).toJson(),
          'GetCompressedTokenBalancesByOwnerRequest' =>
            GetCompressedTokenBalancesByOwnerRequest.fromJson(json).toJson(),
          'GetCompressionSignaturesForAccountRequest' =>
            GetCompressionSignaturesForAccountRequest.fromJson(json).toJson(),
          'GetCompressionSignaturesForAddressRequest' =>
            GetCompressionSignaturesForAddressRequest.fromJson(json).toJson(),
          'GetCompressionSignaturesForOwnerRequest' =>
            GetCompressionSignaturesForOwnerRequest.fromJson(json).toJson(),
          'GetCompressionSignaturesForTokenOwnerRequest' =>
            GetCompressionSignaturesForTokenOwnerRequest.fromJson(json)
                .toJson(),
          'GetLatestCompressionSignaturesRequest' =>
            GetLatestCompressionSignaturesRequest.fromJson(json).toJson(),
          'GetLatestNonVotingSignaturesRequest' =>
            GetLatestNonVotingSignaturesRequest.fromJson(json).toJson(),
          'GetMultipleCompressedAccountProofsRequest' =>
            GetMultipleCompressedAccountProofsRequest.fromJson(json).toJson(),
          'GetMultipleCompressedAccountsRequest' =>
            GetMultipleCompressedAccountsRequest.fromJson(json).toJson(),
          'GetMultipleNewAddressProofsRequest' =>
            GetMultipleNewAddressProofsRequest.fromJson(json).toJson(),
          'GetTransactionWithCompressionInfoRequest' =>
            GetTransactionWithCompressionInfoRequest.fromJson(json).toJson(),
          'GetValidityProofRequest' =>
            GetValidityProofRequest.fromJson(json).toJson(),
          'GetZkSignaturesForAssetRequest' =>
            GetZkSignaturesForAssetRequest.fromJson(json).toJson(),
          _ => throw StateError('Unhandled ${entry.key}'),
        };
        expect(actual, json);
      });
    }

    expectJsonRoundTrip(
      'CompressedAccountList roundtrips',
      {
        'items': [
          {
            'hash': 'hash-1',
            'address': 'address-1',
            'data': {'program': 'memo'},
            'owner': 'owner-1',
            'lamports': 10,
          },
        ],
        'cursor': 'cursor-1',
      },
      CompressedAccountList.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedTokenAccountList roundtrips',
      {
        'items': [
          {
            'hash': 'hash-1',
            'owner': 'owner-1',
            'mint': 'mint-1',
            'amount': 99,
            'frozen': false,
          },
        ],
        'cursor': 'cursor-1',
      },
      CompressedTokenAccountList.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedSignatureList roundtrips',
      {
        'items': [
          {'signature': 'sig-1', 'slot': 9, 'blockTime': 123456},
        ],
        'cursor': 'cursor-1',
      },
      CompressedSignatureList.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedTokenBalanceList roundtrips',
      {
        'items': [
          {'mint': 'mint-1', 'amount': 10},
        ],
        'cursor': 'cursor-1',
      },
      CompressedTokenBalanceList.fromJson,
      (value) => value.toJson(),
    );
    expectJsonRoundTrip(
      'CompressedTokenBalanceV2List roundtrips',
      {
        'items': [
          {'mint': 'mint-1', 'amount': 10, 'decimals': 6},
        ],
        'cursor': 'cursor-1',
      },
      CompressedTokenBalanceV2List.fromJson,
      (value) => value.toJson(),
    );
  });
}
