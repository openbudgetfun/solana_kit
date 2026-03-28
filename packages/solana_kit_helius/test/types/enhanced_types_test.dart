import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('enhanced transaction types', () {
    expectJsonRoundTrip(
      'GetTransactionsRequest roundtrips',
      {
        'transactions': ['sig-1', 'sig-2'],
      },
      GetTransactionsRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'GetTransactionsByAddressRequest roundtrips with commitment',
      {
        'address': 'wallet-1',
        'before': 'sig-before',
        'until': 'sig-until',
        'commitment': 'confirmed',
        'type': 'NFT_SALE',
      },
      GetTransactionsByAddressRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'NativeTransfer roundtrips',
      {
        'fromUserAccount': 'from',
        'toUserAccount': 'to',
        'amount': 10,
      },
      NativeTransfer.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'TokenTransfer roundtrips',
      {
        'fromUserAccount': 'from',
        'toUserAccount': 'to',
        'fromTokenAccount': 'from-token',
        'toTokenAccount': 'to-token',
        'tokenAmount': 5,
        'mint': 'mint-1',
        'tokenStandard': 'FungibleToken',
      },
      TokenTransfer.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'TokenBalanceChange roundtrips',
      {
        'mint': 'mint-1',
        'rawTokenAmount': 500,
        'decimals': 6,
        'userAccount': 'user-1',
        'tokenAccount': 'token-1',
      },
      TokenBalanceChange.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'AccountData roundtrips nested token changes',
      {
        'account': 'acct-1',
        'nativeBalanceChange': {'delta': -5},
        'tokenBalanceChanges': [
          {
            'mint': 'mint-1',
            'rawTokenAmount': 500,
            'decimals': 6,
            'userAccount': 'user-1',
            'tokenAccount': 'token-1',
          },
        ],
      },
      AccountData.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'InnerInstruction roundtrips',
      {
        'accounts': ['a', 1, {'nested': true}],
        'data': '010203',
        'programId': 'program-1',
        'innerInstructions': {'depth': 2},
      },
      InnerInstruction.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'EnhancedTransaction roundtrips full payload',
      {
        'description': 'mint nft',
        'type': 'NFT_MINT',
        'source': 'MAGIC_EDEN',
        'fee': 5000,
        'feePayer': 100,
        'signature': 'sig-1',
        'slot': 42,
        'timestamp': 1234567890,
        'nativeTransfers': [
          {
            'fromUserAccount': 'from',
            'toUserAccount': 'to',
            'amount': 10,
          },
        ],
        'tokenTransfers': [
          {
            'fromUserAccount': 'from',
            'toUserAccount': 'to',
            'fromTokenAccount': 'from-token',
            'toTokenAccount': 'to-token',
            'tokenAmount': 5,
            'mint': 'mint-1',
            'tokenStandard': 'FungibleToken',
          },
        ],
        'accountData': [
          {
            'account': 'acct-1',
            'nativeBalanceChange': {'delta': -5},
            'tokenBalanceChanges': [
              {
                'mint': 'mint-1',
                'rawTokenAmount': 500,
                'decimals': 6,
                'userAccount': 'user-1',
                'tokenAccount': 'token-1',
              },
            ],
          },
        ],
        'instructions': [
          {
            'accounts': ['a', 1, {'nested': true}],
            'data': '010203',
            'programId': 'program-1',
            'innerInstructions': {'depth': 2},
          },
        ],
        'events': {'kind': 'mint'},
      },
      EnhancedTransaction.fromJson,
      (value) => value.toJson(),
    );
  });
}
