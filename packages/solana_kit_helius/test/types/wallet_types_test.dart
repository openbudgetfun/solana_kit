import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

void main() {
  group('wallet types', () {
    expectJsonRoundTrip(
      'GetIdentityRequest roundtrips',
      {'address': 'wallet-1'},
      GetIdentityRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'GetBatchIdentityRequest roundtrips',
      {
        'addresses': ['wallet-1', 'wallet-2'],
      },
      GetBatchIdentityRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'GetBalancesRequest roundtrips',
      {'address': 'wallet-1'},
      GetBalancesRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'GetHistoryRequest roundtrips',
      {
        'address': 'wallet-1',
        'before': 'sig-before',
        'until': 'sig-until',
        'limit': 20,
        'type': 'SWAP',
      },
      GetHistoryRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'GetTransfersRequest roundtrips',
      {
        'address': 'wallet-1',
        'before': 'sig-before',
        'until': 'sig-until',
        'limit': 10,
      },
      GetTransfersRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'GetFundedByRequest roundtrips',
      {'address': 'wallet-1'},
      GetFundedByRequest.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'Identity roundtrips',
      {
        'name': 'Loris',
        'pfpUrl': 'https://example.com/pfp.png',
        'domain': 'loris.sol',
        'socials': {
          'twitter': '@loris',
        },
      },
      Identity.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'WalletTokenBalance roundtrips',
      {
        'mint': 'mint-1',
        'amount': 42,
        'decimals': 6,
        'tokenAccount': 'token-account-1',
      },
      WalletTokenBalance.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'WalletBalances roundtrips nested balances',
      {
        'nativeBalance': 12345,
        'tokens': [
          {
            'mint': 'mint-1',
            'amount': 42,
            'decimals': 6,
            'tokenAccount': 'token-account-1',
          },
        ],
      },
      WalletBalances.fromJson,
      (value) => value.toJson(),
    );

    final enhancedTransactionJson = {
      'description': 'swap',
      'type': 'SWAP',
      'source': 'JUPITER',
      'fee': 5000,
      'feePayer': 123,
      'signature': 'sig-1',
      'slot': 99,
      'timestamp': 1234567890,
      'nativeTransfers': [
        {
          'fromUserAccount': 'from',
          'toUserAccount': 'to',
          'amount': 1,
        },
      ],
      'tokenTransfers': [
        {
          'fromUserAccount': 'from',
          'toUserAccount': 'to',
          'fromTokenAccount': 'from-token',
          'toTokenAccount': 'to-token',
          'tokenAmount': 2,
          'mint': 'mint-1',
          'tokenStandard': 'FungibleToken',
        },
      ],
      'accountData': [
        {
          'account': 'acct-1',
          'nativeBalanceChange': {'delta': 1},
          'tokenBalanceChanges': [
            {
              'mint': 'mint-1',
              'rawTokenAmount': 2,
              'decimals': 6,
              'userAccount': 'user',
              'tokenAccount': 'token',
            },
          ],
        },
      ],
      'instructions': [
        {
          'accounts': ['a', 'b'],
          'data': 'deadbeef',
          'programId': 'program-1',
          'innerInstructions': {
            'child': true,
          },
        },
      ],
      'events': {
        'swap': true,
      },
    };

    expectJsonRoundTrip(
      'WalletHistory roundtrips nested enhanced transactions',
      {
        'transactions': [enhancedTransactionJson],
      },
      WalletHistory.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'WalletTransfer roundtrips',
      {
        'signature': 'sig-1',
        'timestamp': 1234567890,
        'from': 'from',
        'to': 'to',
        'amount': 99,
        'mint': 'mint-1',
      },
      WalletTransfer.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'FundedByTransaction roundtrips',
      {
        'signature': 'sig-1',
        'source': 'airdrop',
        'amount': 500,
        'timestamp': 1234567890,
      },
      FundedByTransaction.fromJson,
      (value) => value.toJson(),
    );

    expectJsonRoundTrip(
      'FundedByResult roundtrips',
      {
        'transactions': [
          {
            'signature': 'sig-1',
            'source': 'airdrop',
            'amount': 500,
            'timestamp': 1234567890,
          },
        ],
      },
      FundedByResult.fromJson,
      (value) => value.toJson(),
    );
  });
}
