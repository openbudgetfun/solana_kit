import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // SysvarClock
  // ---------------------------------------------------------------------------
  group('SysvarClock toString and inequality', () {
    test('toString contains all field values', () {
      final clock = SysvarClock(
        slot: BigInt.from(100),
        epochStartTimestamp: BigInt.from(200),
        epoch: BigInt.from(3),
        leaderScheduleEpoch: BigInt.from(4),
        unixTimestamp: BigInt.from(500),
      );
      final str = clock.toString();
      expect(str, contains('100'));
      expect(str, contains('200'));
      expect(str, contains('3'));
      expect(str, contains('4'));
      expect(str, contains('500'));
      expect(str, contains('SysvarClock'));
    });

    test('not equal when slots differ', () {
      final a = SysvarClock(
        slot: BigInt.from(1),
        epochStartTimestamp: BigInt.zero,
        epoch: BigInt.zero,
        leaderScheduleEpoch: BigInt.zero,
        unixTimestamp: BigInt.zero,
      );
      final b = SysvarClock(
        slot: BigInt.from(2),
        epochStartTimestamp: BigInt.zero,
        epoch: BigInt.zero,
        leaderScheduleEpoch: BigInt.zero,
        unixTimestamp: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when epochStartTimestamp differs', () {
      final a = SysvarClock(
        slot: BigInt.zero,
        epochStartTimestamp: BigInt.from(1),
        epoch: BigInt.zero,
        leaderScheduleEpoch: BigInt.zero,
        unixTimestamp: BigInt.zero,
      );
      final b = SysvarClock(
        slot: BigInt.zero,
        epochStartTimestamp: BigInt.from(2),
        epoch: BigInt.zero,
        leaderScheduleEpoch: BigInt.zero,
        unixTimestamp: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when unixTimestamp differs', () {
      final base = SysvarClock(
        slot: BigInt.zero,
        epochStartTimestamp: BigInt.zero,
        epoch: BigInt.zero,
        leaderScheduleEpoch: BigInt.zero,
        unixTimestamp: BigInt.from(10),
      );
      final other = SysvarClock(
        slot: BigInt.zero,
        epochStartTimestamp: BigInt.zero,
        epoch: BigInt.zero,
        leaderScheduleEpoch: BigInt.zero,
        unixTimestamp: BigInt.from(20),
      );
      expect(base, isNot(equals(other)));
    });

    test('getSysvarClockDecoder has correct fixed size', () {
      final decoder = getSysvarClockDecoder();
      expect(decoder.fixedSize, equals(sysvarClockSize));
      expect(isFixedSize(decoder), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // SysvarRent
  // ---------------------------------------------------------------------------
  group('SysvarRent toString and extras', () {
    test('toString contains field values', () {
      final rent = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(3480)),
        exemptionThreshold: 2.5,
        burnPercent: 50,
      );
      final str = rent.toString();
      expect(str, contains('3480'));
      expect(str, contains('2.5'));
      expect(str, contains('50'));
      expect(str, contains('SysvarRent'));
    });

    test('not equal when burnPercent differs', () {
      final a = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(100)),
        exemptionThreshold: 2,
        burnPercent: 10,
      );
      final b = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(100)),
        exemptionThreshold: 2,
        burnPercent: 20,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when exemptionThreshold differs', () {
      final a = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(100)),
        exemptionThreshold: 1,
        burnPercent: 10,
      );
      final b = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(100)),
        exemptionThreshold: 2,
        burnPercent: 10,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when lamportsPerByteYear differs', () {
      final a = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(100)),
        exemptionThreshold: 2,
        burnPercent: 10,
      );
      final b = SysvarRent(
        lamportsPerByteYear: Lamports(BigInt.from(200)),
        exemptionThreshold: 2,
        burnPercent: 10,
      );
      expect(a, isNot(equals(b)));
    });

    test('getSysvarRentDecoder has correct fixed size', () {
      final decoder = getSysvarRentDecoder();
      expect(decoder.fixedSize, equals(sysvarRentSize));
      expect(isFixedSize(decoder), isTrue);
    });

    test('getSysvarRentCodec has correct fixed size', () {
      final codec = getSysvarRentCodec();
      expect(codec.fixedSize, equals(sysvarRentSize));
      expect(isFixedSize(codec), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // SysvarEpochSchedule
  // ---------------------------------------------------------------------------
  group('SysvarEpochSchedule toString and inequality', () {
    test('toString contains field values', () {
      final schedule = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(10000),
        leaderScheduleSlotOffset: BigInt.from(150000),
        warmup: true,
        firstNormalEpoch: BigInt.from(550),
        firstNormalSlot: BigInt.from(350000),
      );
      final str = schedule.toString();
      expect(str, contains('10000'));
      expect(str, contains('150000'));
      expect(str, contains('true'));
      expect(str, contains('550'));
      expect(str, contains('350000'));
      expect(str, contains('SysvarEpochSchedule'));
    });

    test('not equal when slotsPerEpoch differs', () {
      final a = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(432000),
        leaderScheduleSlotOffset: BigInt.from(432000),
        warmup: false,
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
      );
      final b = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(216000),
        leaderScheduleSlotOffset: BigInt.from(432000),
        warmup: false,
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });

    test('not equal when warmup differs', () {
      final a = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(432000),
        leaderScheduleSlotOffset: BigInt.from(432000),
        warmup: false,
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
      );
      final b = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(432000),
        leaderScheduleSlotOffset: BigInt.from(432000),
        warmup: true,
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
      );
      expect(a, isNot(equals(b)));
    });

    test('getSysvarEpochScheduleDecoder has correct fixed size', () {
      final decoder = getSysvarEpochScheduleDecoder();
      expect(decoder.fixedSize, equals(sysvarEpochScheduleSize));
      expect(isFixedSize(decoder), isTrue);
    });

    test('getSysvarEpochScheduleCodec has correct fixed size', () {
      final codec = getSysvarEpochScheduleCodec();
      expect(codec.fixedSize, equals(sysvarEpochScheduleSize));
      expect(isFixedSize(codec), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // SysvarEpochRewards
  // ---------------------------------------------------------------------------
  group('SysvarEpochRewards toString and inequality', () {
    test('toString contains field values', () {
      final rewards = SysvarEpochRewards(
        distributionStartingBlockHeight: BigInt.from(1000),
        numPartitions: BigInt.from(10),
        parentBlockhash: const Blockhash(
          '7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj',
        ),
        totalPoints: BigInt.from(5000),
        totalRewards: Lamports(BigInt.from(500)),
        distributedRewards: Lamports(BigInt.from(200)),
        active: true,
      );
      final str = rewards.toString();
      expect(str, contains('1000'));
      expect(str, contains('10'));
      expect(str, contains('5000'));
      expect(str, contains('500'));
      expect(str, contains('true'));
      expect(str, contains('SysvarEpochRewards'));
    });

    test('not equal when active differs', () {
      final base = SysvarEpochRewards(
        distributionStartingBlockHeight: BigInt.zero,
        numPartitions: BigInt.zero,
        parentBlockhash: const Blockhash(
          '7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj',
        ),
        totalPoints: BigInt.zero,
        totalRewards: Lamports(BigInt.zero),
        distributedRewards: Lamports(BigInt.zero),
        active: true,
      );
      final other = SysvarEpochRewards(
        distributionStartingBlockHeight: BigInt.zero,
        numPartitions: BigInt.zero,
        parentBlockhash: const Blockhash(
          '7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj',
        ),
        totalPoints: BigInt.zero,
        totalRewards: Lamports(BigInt.zero),
        distributedRewards: Lamports(BigInt.zero),
        active: false,
      );
      expect(base, isNot(equals(other)));
    });

    test('not equal when totalRewards differs', () {
      SysvarEpochRewards make(int r) => SysvarEpochRewards(
        distributionStartingBlockHeight: BigInt.zero,
        numPartitions: BigInt.zero,
        parentBlockhash: const Blockhash(
          '7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj',
        ),
        totalPoints: BigInt.zero,
        totalRewards: Lamports(BigInt.from(r)),
        distributedRewards: Lamports(BigInt.zero),
        active: false,
      );
      expect(make(100), isNot(equals(make(200))));
    });

    test('getSysvarEpochRewardsDecoder has correct fixed size', () {
      final decoder = getSysvarEpochRewardsDecoder();
      expect(decoder.fixedSize, equals(sysvarEpochRewardsSize));
      expect(isFixedSize(decoder), isTrue);
    });

    test('getSysvarEpochRewardsCodec has correct fixed size', () {
      final codec = getSysvarEpochRewardsCodec();
      expect(codec.fixedSize, equals(sysvarEpochRewardsSize));
      expect(isFixedSize(codec), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // SysvarSlotHistory
  // ---------------------------------------------------------------------------
  group('SysvarSlotHistory toString and inequality', () {
    test('toString contains nextSlot and bits length', () {
      final bits = List<BigInt>.filled(bitvecLength, BigInt.zero);
      final history = SysvarSlotHistory(bits: bits, nextSlot: BigInt.from(42));
      final str = history.toString();
      expect(str, contains('42'));
      expect(str, contains('SysvarSlotHistory'));
      expect(str, contains('elements'));
    });

    test('not equal when nextSlot differs', () {
      final bits = List<BigInt>.filled(bitvecLength, BigInt.zero);
      final a = SysvarSlotHistory(bits: bits, nextSlot: BigInt.from(10));
      final b = SysvarSlotHistory(bits: bits, nextSlot: BigInt.from(20));
      expect(a, isNot(equals(b)));
    });

    test('not equal when bits differ', () {
      final bitsA = List<BigInt>.filled(bitvecLength, BigInt.zero);
      final bitsB = List<BigInt>.filled(bitvecLength, BigInt.zero);
      bitsB[0] = BigInt.one;
      final a = SysvarSlotHistory(bits: bitsA, nextSlot: BigInt.zero);
      final b = SysvarSlotHistory(bits: bitsB, nextSlot: BigInt.zero);
      expect(a, isNot(equals(b)));
    });

    test('decoder throws SolanaError for wrong byte length', () {
      final decoder = getSysvarSlotHistoryDecoder();
      // Create data with wrong size (too short).
      final badBytes = Uint8List(10);
      expect(
        () => decoder.read(badBytes, 0),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsInvalidByteLength,
          ),
        ),
      );
    });

    test('decoder throws SolanaError for wrong discriminator', () {
      final decoder = getSysvarSlotHistoryDecoder();
      // Create data of correct size but with wrong discriminator.
      final bytes = Uint8List(sysvarSlotHistorySize);
      bytes[0] = 99; // Wrong discriminator.
      expect(
        () => decoder.read(bytes, 0),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsEnumDiscriminatorOutOfRange,
          ),
        ),
      );
    });

    test('decoder throws SolanaError for wrong bitvec length', () {
      final decoder = getSysvarSlotHistoryDecoder();
      final bytes = Uint8List(sysvarSlotHistorySize);
      // Correct discriminator.
      bytes[0] = bitvecDiscriminator;
      // Wrong bitvec length: write 99 as u64 little-endian at offset 1.
      bytes[1] = 99;
      // Fill rest with valid bits for the bitvec section (all zeros),
      // but the numBits field at the expected offset also needs to be correct.
      // Since bitVecLength is wrong this should throw first.
      expect(
        () => decoder.read(bytes, 0),
        throwsA(
          isA<SolanaError>().having(
            (e) => e.code,
            'code',
            SolanaErrorCode.codecsInvalidNumberOfItems,
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // StakeHistory types
  // ---------------------------------------------------------------------------
  group('StakeHistoryData and StakeHistoryEntry toString', () {
    test('StakeHistoryData toString contains field values', () {
      final data = StakeHistoryData(
        effective: Lamports(BigInt.from(100)),
        activating: Lamports(BigInt.from(200)),
        deactivating: Lamports(BigInt.from(300)),
      );
      final str = data.toString();
      expect(str, contains('100'));
      expect(str, contains('200'));
      expect(str, contains('300'));
      expect(str, contains('StakeHistoryData'));
    });

    test('StakeHistoryData not equal when effective differs', () {
      final a = StakeHistoryData(
        effective: Lamports(BigInt.from(100)),
        activating: Lamports(BigInt.zero),
        deactivating: Lamports(BigInt.zero),
      );
      final b = StakeHistoryData(
        effective: Lamports(BigInt.from(200)),
        activating: Lamports(BigInt.zero),
        deactivating: Lamports(BigInt.zero),
      );
      expect(a, isNot(equals(b)));
    });

    test('StakeHistoryData not equal when activating differs', () {
      final a = StakeHistoryData(
        effective: Lamports(BigInt.zero),
        activating: Lamports(BigInt.from(100)),
        deactivating: Lamports(BigInt.zero),
      );
      final b = StakeHistoryData(
        effective: Lamports(BigInt.zero),
        activating: Lamports(BigInt.from(200)),
        deactivating: Lamports(BigInt.zero),
      );
      expect(a, isNot(equals(b)));
    });

    test('StakeHistoryEntry toString contains field values', () {
      final entry = StakeHistoryEntry(
        epoch: BigInt.from(5),
        stakeHistory: StakeHistoryData(
          effective: Lamports(BigInt.from(100)),
          activating: Lamports(BigInt.from(200)),
          deactivating: Lamports(BigInt.from(300)),
        ),
      );
      final str = entry.toString();
      expect(str, contains('5'));
      expect(str, contains('StakeHistoryEntry'));
    });

    test('StakeHistoryEntry not equal when epoch differs', () {
      final history = StakeHistoryData(
        effective: Lamports(BigInt.zero),
        activating: Lamports(BigInt.zero),
        deactivating: Lamports(BigInt.zero),
      );
      final a = StakeHistoryEntry(epoch: BigInt.from(1), stakeHistory: history);
      final b = StakeHistoryEntry(epoch: BigInt.from(2), stakeHistory: history);
      expect(a, isNot(equals(b)));
    });

    test('getSysvarStakeHistoryCodec encodes empty list', () {
      final codec = getSysvarStakeHistoryCodec();
      final encoded = codec.encode([]);
      final decoded = codec.decode(encoded);
      expect(decoded, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // SlotHashEntry
  // ---------------------------------------------------------------------------
  group('SlotHashEntry toString and inequality', () {
    test('toString contains slot and hash', () {
      final entry = SlotHashEntry(
        slot: BigInt.from(999),
        hash: const Blockhash('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'),
      );
      final str = entry.toString();
      expect(str, contains('999'));
      expect(str, contains('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'));
      expect(str, contains('SlotHashEntry'));
    });

    test('not equal when slot differs', () {
      const hash = Blockhash(
        '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
      );
      final a = SlotHashEntry(slot: BigInt.from(1), hash: hash);
      final b = SlotHashEntry(slot: BigInt.from(2), hash: hash);
      expect(a, isNot(equals(b)));
    });

    test('not equal when hash differs', () {
      final a = SlotHashEntry(
        slot: BigInt.one,
        hash: const Blockhash('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'),
      );
      final b = SlotHashEntry(
        slot: BigInt.one,
        hash: const Blockhash('8qbHbw2BbbTHBW1sbeqakYXVKRQM8Ne7pLK7m6CVfeR'),
      );
      expect(a, isNot(equals(b)));
    });

    test('getSysvarSlotHashesCodec encodes empty list', () {
      final codec = getSysvarSlotHashesCodec();
      final encoded = codec.encode([]);
      final decoded = codec.decode(encoded);
      expect(decoded, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // RecentBlockhashes types
  // ---------------------------------------------------------------------------
  group('FeeCalculator and RecentBlockhashEntry toString and inequality', () {
    test('FeeCalculator toString contains lamportsPerSignature', () {
      final fc = FeeCalculator(
        lamportsPerSignature: Lamports(BigInt.from(5000)),
      );
      final str = fc.toString();
      expect(str, contains('5000'));
      expect(str, contains('FeeCalculator'));
    });

    test('FeeCalculator not equal when lamportsPerSignature differs', () {
      final a = FeeCalculator(
        lamportsPerSignature: Lamports(BigInt.from(100)),
      );
      final b = FeeCalculator(
        lamportsPerSignature: Lamports(BigInt.from(200)),
      );
      expect(a, isNot(equals(b)));
    });

    test('RecentBlockhashEntry toString contains blockhash and fee', () {
      final entry = RecentBlockhashEntry(
        blockhash: const Blockhash(
          '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
        ),
        feeCalculator: FeeCalculator(
          lamportsPerSignature: Lamports(BigInt.from(5000)),
        ),
      );
      final str = entry.toString();
      expect(str, contains('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'));
      expect(str, contains('RecentBlockhashEntry'));
    });

    test('RecentBlockhashEntry not equal when feeCalculator differs', () {
      const bh = Blockhash(
        '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
      );
      final a = RecentBlockhashEntry(
        blockhash: bh,
        feeCalculator: FeeCalculator(
          lamportsPerSignature: Lamports(BigInt.from(100)),
        ),
      );
      final b = RecentBlockhashEntry(
        blockhash: bh,
        feeCalculator: FeeCalculator(
          lamportsPerSignature: Lamports(BigInt.from(200)),
        ),
      );
      expect(a, isNot(equals(b)));
    });

    test('getSysvarRecentBlockhashesCodec encodes empty list', () {
      final codec = getSysvarRecentBlockhashesCodec();
      final encoded = codec.encode([]);
      final decoded = codec.decode(encoded);
      expect(decoded, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // SysvarLastRestartSlot
  // ---------------------------------------------------------------------------
  group('SysvarLastRestartSlot toString and inequality', () {
    test('toString contains lastRestartSlot value', () {
      final slot = SysvarLastRestartSlot(lastRestartSlot: BigInt.from(12345));
      final str = slot.toString();
      expect(str, contains('12345'));
      expect(str, contains('SysvarLastRestartSlot'));
    });

    test('not equal when lastRestartSlot differs', () {
      final a = SysvarLastRestartSlot(lastRestartSlot: BigInt.from(100));
      final b = SysvarLastRestartSlot(lastRestartSlot: BigInt.from(200));
      expect(a, isNot(equals(b)));
    });

    test('getSysvarLastRestartSlotDecoder has correct fixed size', () {
      final decoder = getSysvarLastRestartSlotDecoder();
      expect(decoder.fixedSize, equals(sysvarLastRestartSlotSize));
      expect(isFixedSize(decoder), isTrue);
    });

    test('getSysvarLastRestartSlotCodec has correct fixed size', () {
      final codec = getSysvarLastRestartSlotCodec();
      expect(codec.fixedSize, equals(sysvarLastRestartSlotSize));
      expect(isFixedSize(codec), isTrue);
    });
  });
}
