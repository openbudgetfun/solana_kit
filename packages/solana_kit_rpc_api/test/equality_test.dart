import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

const _addr1 = Address('11111111111111111111111111111111');
const _sig1 = Signature('1111111111111111111111111111111111111111111111111111111111111111');

void main() {
  // ---------------------------------------------------------------------------
  // GetAccountInfoConfig
  // ---------------------------------------------------------------------------
  group('GetAccountInfoConfig equality', () {
    test('equal when all fields match', () {
      final a = GetAccountInfoConfig(
        commitment: Commitment.confirmed,
        encoding: AccountEncoding.base64,
        dataSlice: const DataSlice(offset: 0, length: 32),
        minContextSlot: BigInt.from(100),
      );
      final b = GetAccountInfoConfig(
        commitment: Commitment.confirmed,
        encoding: AccountEncoding.base64,
        dataSlice: const DataSlice(offset: 0, length: 32),
        minContextSlot: BigInt.from(100),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal when all null', () {
      const a = GetAccountInfoConfig();
      const b = GetAccountInfoConfig();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when commitment differs', () {
      const a = GetAccountInfoConfig(commitment: Commitment.confirmed);
      const b = GetAccountInfoConfig(commitment: Commitment.finalized);
      expect(a, isNot(equals(b)));
    });

    test('not equal when encoding differs', () {
      const a = GetAccountInfoConfig(encoding: AccountEncoding.base64);
      const b = GetAccountInfoConfig(encoding: AccountEncoding.base58);
      expect(a, isNot(equals(b)));
    });

    test('identical instance equals itself', () {
      const a = GetAccountInfoConfig(commitment: Commitment.processed);
      expect(a, equals(a));
    });
  });

  // ---------------------------------------------------------------------------
  // GetBalanceConfig
  // ---------------------------------------------------------------------------
  group('GetBalanceConfig equality', () {
    test('equal when all null', () {
      const a = GetBalanceConfig();
      const b = GetBalanceConfig();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when commitment differs', () {
      const a = GetBalanceConfig(commitment: Commitment.confirmed);
      const b = GetBalanceConfig(commitment: Commitment.finalized);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // GetBlockConfig
  // ---------------------------------------------------------------------------
  group('GetBlockConfig equality', () {
    test('equal when all fields match', () {
      const a = GetBlockConfig(
        commitment: Commitment.confirmed,
        encoding: TransactionEncoding.base64,
        maxSupportedTransactionVersion: 0,
        rewards: false,
        transactionDetails: 'full',
      );
      const b = GetBlockConfig(
        commitment: Commitment.confirmed,
        encoding: TransactionEncoding.base64,
        maxSupportedTransactionVersion: 0,
        rewards: false,
        transactionDetails: 'full',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when transactionDetails differs', () {
      const a = GetBlockConfig(transactionDetails: 'full');
      const b = GetBlockConfig(transactionDetails: 'none');
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // SlotRange
  // ---------------------------------------------------------------------------
  group('SlotRange equality', () {
    test('equal when firstSlot and lastSlot match', () {
      final a = SlotRange(
        firstSlot: BigInt.from(10),
        lastSlot: BigInt.from(20),
      );
      final b = SlotRange(
        firstSlot: BigInt.from(10),
        lastSlot: BigInt.from(20),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal when lastSlot is null', () {
      final a = SlotRange(firstSlot: BigInt.from(5));
      final b = SlotRange(firstSlot: BigInt.from(5));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when firstSlot differs', () {
      final a = SlotRange(firstSlot: BigInt.from(5));
      final b = SlotRange(firstSlot: BigInt.from(10));
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // GetBlockProductionConfig
  // ---------------------------------------------------------------------------
  group('GetBlockProductionConfig equality', () {
    test('equal when all null', () {
      const a = GetBlockProductionConfig();
      const b = GetBlockProductionConfig();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when identity differs', () {
      const a = GetBlockProductionConfig(identity: _addr1);
      const b = GetBlockProductionConfig();
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // EpochInfo
  // ---------------------------------------------------------------------------
  group('EpochInfo equality', () {
    test('equal when all fields match', () {
      final a = EpochInfo(
        absoluteSlot: BigInt.from(100),
        blockHeight: BigInt.from(90),
        epoch: BigInt.from(1),
        slotIndex: BigInt.from(50),
        slotsInEpoch: BigInt.from(432000),
        transactionCount: BigInt.from(999),
      );
      final b = EpochInfo(
        absoluteSlot: BigInt.from(100),
        blockHeight: BigInt.from(90),
        epoch: BigInt.from(1),
        slotIndex: BigInt.from(50),
        slotsInEpoch: BigInt.from(432000),
        transactionCount: BigInt.from(999),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when epoch differs', () {
      final a = EpochInfo(
        absoluteSlot: BigInt.from(100),
        blockHeight: BigInt.from(90),
        epoch: BigInt.from(1),
        slotIndex: BigInt.from(50),
        slotsInEpoch: BigInt.from(432000),
      );
      final b = EpochInfo(
        absoluteSlot: BigInt.from(100),
        blockHeight: BigInt.from(90),
        epoch: BigInt.from(2),
        slotIndex: BigInt.from(50),
        slotsInEpoch: BigInt.from(432000),
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // EpochSchedule
  // ---------------------------------------------------------------------------
  group('EpochSchedule equality', () {
    test('equal when all fields match', () {
      final a = EpochSchedule(
        firstNormalEpoch: BigInt.from(14),
        firstNormalSlot: BigInt.from(524288),
        leaderScheduleSlotOffset: BigInt.from(432000),
        slotsPerEpoch: BigInt.from(432000),
        warmup: true,
      );
      final b = EpochSchedule(
        firstNormalEpoch: BigInt.from(14),
        firstNormalSlot: BigInt.from(524288),
        leaderScheduleSlotOffset: BigInt.from(432000),
        slotsPerEpoch: BigInt.from(432000),
        warmup: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when warmup differs', () {
      final a = EpochSchedule(
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
        leaderScheduleSlotOffset: BigInt.zero,
        slotsPerEpoch: BigInt.from(432000),
        warmup: true,
      );
      final b = EpochSchedule(
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
        leaderScheduleSlotOffset: BigInt.zero,
        slotsPerEpoch: BigInt.from(432000),
        warmup: false,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // SendTransactionConfig
  // ---------------------------------------------------------------------------
  group('SendTransactionConfig equality', () {
    test('equal when all null', () {
      const a = SendTransactionConfig();
      const b = SendTransactionConfig();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal when all fields match', () {
      final a = SendTransactionConfig(
        encoding: WireTransactionEncoding.base64,
        maxRetries: BigInt.from(3),
        minContextSlot: BigInt.from(1000),
        preflightCommitment: Commitment.confirmed,
        skipPreflight: false,
      );
      final b = SendTransactionConfig(
        encoding: WireTransactionEncoding.base64,
        maxRetries: BigInt.from(3),
        minContextSlot: BigInt.from(1000),
        preflightCommitment: Commitment.confirmed,
        skipPreflight: false,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when skipPreflight differs', () {
      const a = SendTransactionConfig(skipPreflight: true);
      const b = SendTransactionConfig(skipPreflight: false);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // SimulateTransactionConfig
  // ---------------------------------------------------------------------------
  group('SimulateTransactionConfig equality', () {
    test('equal when all null', () {
      const a = SimulateTransactionConfig();
      const b = SimulateTransactionConfig();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when commitment differs', () {
      const a = SimulateTransactionConfig(
        commitment: Commitment.confirmed,
      );
      const b = SimulateTransactionConfig(
        commitment: Commitment.finalized,
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // SimulateTransactionAccountsConfig
  // ---------------------------------------------------------------------------
  group('SimulateTransactionAccountsConfig equality', () {
    test('equal when addresses and encoding match', () {
      const a = SimulateTransactionAccountsConfig(
        addresses: [_addr1],
        encoding: AccountEncoding.base64,
      );
      const b = SimulateTransactionAccountsConfig(
        addresses: [_addr1],
        encoding: AccountEncoding.base64,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when addresses differ', () {
      const a = SimulateTransactionAccountsConfig(
        addresses: [_addr1],
      );
      const b = SimulateTransactionAccountsConfig(
        addresses: [],
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // TokenAccountMintFilter
  // ---------------------------------------------------------------------------
  group('TokenAccountMintFilter equality', () {
    test('equal when mint matches', () {
      const a = TokenAccountMintFilter(mint: _addr1);
      const b = TokenAccountMintFilter(mint: _addr1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when mint differs', () {
      const a = TokenAccountMintFilter(mint: _addr1);
      const b = TokenAccountMintFilter(
        mint: Address('22222222222222222222222222222222'),
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // TokenAccountProgramIdFilter
  // ---------------------------------------------------------------------------
  group('TokenAccountProgramIdFilter equality', () {
    test('equal when programId matches', () {
      const a = TokenAccountProgramIdFilter(programId: _addr1);
      const b = TokenAccountProgramIdFilter(programId: _addr1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // GetSignaturesForAddressConfig
  // ---------------------------------------------------------------------------
  group('GetSignaturesForAddressConfig equality', () {
    test('equal when all null', () {
      const a = GetSignaturesForAddressConfig();
      const b = GetSignaturesForAddressConfig();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when limit differs', () {
      const a = GetSignaturesForAddressConfig(limit: 10);
      const b = GetSignaturesForAddressConfig(limit: 20);
      expect(a, isNot(equals(b)));
    });

    test('equal when before signature matches', () {
      const a = GetSignaturesForAddressConfig(before: _sig1);
      const b = GetSignaturesForAddressConfig(before: _sig1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  // ---------------------------------------------------------------------------
  // GetVoteAccountsConfig
  // ---------------------------------------------------------------------------
  group('GetVoteAccountsConfig equality', () {
    test('equal when all null', () {
      const a = GetVoteAccountsConfig();
      const b = GetVoteAccountsConfig();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when keepUnstakedDelinquents differs', () {
      const a = GetVoteAccountsConfig(keepUnstakedDelinquents: true);
      const b = GetVoteAccountsConfig(keepUnstakedDelinquents: false);
      expect(a, isNot(equals(b)));
    });
  });

  // ---------------------------------------------------------------------------
  // ClusterNode
  // ---------------------------------------------------------------------------
  group('ClusterNode equality', () {
    test('equal when all fields match', () {
      const a = ClusterNode(
        pubkey: _addr1,
        gossip: '127.0.0.1:8001',
        version: '1.18.0',
      );
      const b = ClusterNode(
        pubkey: _addr1,
        gossip: '127.0.0.1:8001',
        version: '1.18.0',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('not equal when version differs', () {
      const a = ClusterNode(pubkey: _addr1, version: '1.18.0');
      const b = ClusterNode(pubkey: _addr1, version: '1.17.0');
      expect(a, isNot(equals(b)));
    });
  });
}
