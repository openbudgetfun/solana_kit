// This file verifies deprecated status model compatibility during transition.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _accountA = Address('11111111111111111111111111111111');
const _accountB = Address('TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA');

void main() {
  group('Transaction version and lookup models', () {
    test('version variants expose stable string forms', () {
      expect(const TransactionVersionLegacy().toString(), 'legacy');
      expect(const TransactionVersionV0().toString(), '0');
    });

    test('AddressTableLookup retains keys and index sets', () {
      const lookup = AddressTableLookup(
        accountKey: _accountA,
        readonlyIndexes: [0, 2],
        writableIndexes: [1, 3],
      );

      expect(lookup.accountKey, _accountA);
      expect(lookup.readonlyIndexes, [0, 2]);
      expect(lookup.writableIndexes, [1, 3]);
    });
  });

  group('Reward models', () {
    test('RewardFeeOrRent stores all shared reward fields', () {
      final reward = RewardFeeOrRent(
        rewardLamports: -BigInt.from(1000),
        postBalance: lamports(BigInt.from(50_000)),
        pubkey: _accountA,
        rewardType: 'rent',
      );

      expect(reward.rewardLamports, -BigInt.from(1000));
      expect(reward.postBalance, lamports(BigInt.from(50_000)));
      expect(reward.pubkey, _accountA);
      expect(reward.rewardType, 'rent');
    });

    test('RewardVotingOrStaking includes commission', () {
      final reward = RewardVotingOrStaking(
        rewardLamports: BigInt.from(2_500),
        postBalance: lamports(BigInt.from(100_000)),
        pubkey: _accountB,
        rewardType: 'voting',
        commission: 8,
      );

      expect(reward.rewardLamports, BigInt.from(2_500));
      expect(reward.postBalance, lamports(BigInt.from(100_000)));
      expect(reward.pubkey, _accountB);
      expect(reward.rewardType, 'voting');
      expect(reward.commission, 8);
    });
  });

  group('Transaction status and metadata models', () {
    test('deprecated TransactionStatus variants are constructible', () {
      const ok = TransactionStatusOk();
      const err = TransactionStatusErr(
        TransactionErrorSimple('AccountInUse'),
      );

      expect(ok, isA<TransactionStatus>());
      expect(err, isA<TransactionStatus>());
      expect(err.error.label, 'AccountInUse');
    });

    test('TransactionForAccountsMetaBase stores balance/token metadata', () {
      const tokenAmount = TokenAmount(
        amount: StringifiedBigInt('100'),
        decimals: 2,
        uiAmountString: StringifiedNumber('1'),
      );
      const tokenBalance = TokenBalance(
        accountIndex: 1,
        mint: _accountB,
        owner: _accountA,
        programId: _accountB,
        uiTokenAmount: tokenAmount,
      );

      final meta = TransactionForAccountsMetaBase(
        err: const TransactionErrorSimple('SignatureFailure'),
        fee: lamports(BigInt.from(5000)),
        preBalances: [lamports(BigInt.from(10_000))],
        postBalances: [lamports(BigInt.from(5_000))],
        preTokenBalances: const [tokenBalance],
        postTokenBalances: const [tokenBalance],
      );

      expect(meta.err?.label, 'SignatureFailure');
      expect(meta.fee, lamports(BigInt.from(5000)));
      expect(meta.preBalances.first, lamports(BigInt.from(10_000)));
      expect(meta.postBalances.first, lamports(BigInt.from(5_000)));
      expect(meta.preTokenBalances?.first, tokenBalance);
      expect(meta.postTokenBalances?.first, tokenBalance);
    });
  });

  group('Return and parsed account models', () {
    test('ReturnData stores program id and encoded tuple', () {
      const returnData = ReturnData(
        data: (Base64EncodedBytes('AQID'), 'base64'),
        programId: _accountA,
      );

      expect(returnData.programId, _accountA);
      expect(returnData.data.$1, const Base64EncodedBytes('AQID'));
      expect(returnData.data.$2, 'base64');
    });

    test('TransactionParsedAccount stores parsed account metadata', () {
      const parsedAccount = TransactionParsedAccount(
        pubkey: _accountB,
        signer: true,
        writable: false,
        source: 'lookupTable',
      );

      expect(parsedAccount.pubkey, _accountB);
      expect(parsedAccount.signer, isTrue);
      expect(parsedAccount.writable, isFalse);
      expect(parsedAccount.source, 'lookupTable');
    });
  });
}
