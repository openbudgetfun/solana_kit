import 'package:solana_kit_rpc_parsed_types/solana_kit_rpc_parsed_types.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('JsonParsedSysvarAccount', () {
    test('can construct a clock sysvar', () {
      final account = JsonParsedClockSysvar(
        info: JsonParsedClockInfo(
          epoch: BigInt.zero,
          epochStartTimestamp: UnixTimestamp(BigInt.from(1704907181)),
          leaderScheduleEpoch: BigInt.one,
          slot: BigInt.from(90829),
          unixTimestamp: UnixTimestamp(BigInt.from(1704998009)),
        ),
      );

      expect(account.type, 'clock');
      expect(account.info.epoch, BigInt.zero);
      expect(account.info.epochStartTimestamp.value, BigInt.from(1704907181));
      expect(account.info.leaderScheduleEpoch, BigInt.one);
      expect(account.info.slot, BigInt.from(90829));
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct an epochSchedule sysvar', () {
      final account = JsonParsedEpochScheduleSysvar(
        info: JsonParsedEpochScheduleInfo(
          firstNormalEpoch: BigInt.zero,
          firstNormalSlot: BigInt.zero,
          leaderScheduleSlotOffset: BigInt.from(432000),
          slotsPerEpoch: BigInt.from(432000),
          warmup: false,
        ),
      );

      expect(account.type, 'epochSchedule');
      expect(account.info.firstNormalEpoch, BigInt.zero);
      expect(account.info.slotsPerEpoch, BigInt.from(432000));
      expect(account.info.warmup, isFalse);
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct a fees sysvar (deprecated)', () {
      const account = JsonParsedFeesSysvar(
        info: JsonParsedFeesInfo(
          feeCalculator: JsonParsedFeeCalculator(
            lamportsPerSignature: StringifiedBigInt('0'),
          ),
        ),
      );

      expect(account.type, 'fees');
      expect(account.info.feeCalculator.lamportsPerSignature.value, '0');
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct a recentBlockhashes sysvar (deprecated)', () {
      const account = JsonParsedRecentBlockhashesSysvar(
        info: [
          JsonParsedRecentBlockhashEntry(
            blockhash: Blockhash(
              'Gy5GKD5p7UmUWF2BEm3TAUP4PSLTw9puSUbuoH5xPdzk',
            ),
            feeCalculator: JsonParsedFeeCalculator(
              lamportsPerSignature: StringifiedBigInt('5000'),
            ),
          ),
          JsonParsedRecentBlockhashEntry(
            blockhash: Blockhash(
              'FvNKRQk7TuFXVmXEM4XEubXdYREaeiWX56SL97taEhAQ',
            ),
            feeCalculator: JsonParsedFeeCalculator(
              lamportsPerSignature: StringifiedBigInt('5000'),
            ),
          ),
        ],
      );

      expect(account.type, 'recentBlockhashes');
      expect(account.info, hasLength(2));
      expect(
        account.info[0].blockhash.value,
        'Gy5GKD5p7UmUWF2BEm3TAUP4PSLTw9puSUbuoH5xPdzk',
      );
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct a rent sysvar', () {
      const account = JsonParsedRentSysvar(
        info: JsonParsedRentInfo(
          burnPercent: 50,
          exemptionThreshold: 2,
          lamportsPerByteYear: StringifiedBigInt('3480'),
        ),
      );

      expect(account.type, 'rent');
      expect(account.info.burnPercent, 50);
      expect(account.info.exemptionThreshold, 2.0);
      expect(account.info.lamportsPerByteYear.value, '3480');
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct a slotHashes sysvar', () {
      final account = JsonParsedSlotHashesSysvar(
        info: [
          JsonParsedSlotHashEntry(
            hash: 'BAwX3h9EtGqBGnvXqgBoTZL19iHY8PKeCS9AVWFsVLQ8',
            slot: BigInt.from(149694),
          ),
          JsonParsedSlotHashEntry(
            hash: '7HdyQAb5kaZ9RjTuX8uejYXj86J3P2foNfDkqLAFNYFF',
            slot: BigInt.from(149693),
          ),
        ],
      );

      expect(account.type, 'slotHashes');
      expect(account.info, hasLength(2));
      expect(
        account.info[0].hash,
        'BAwX3h9EtGqBGnvXqgBoTZL19iHY8PKeCS9AVWFsVLQ8',
      );
      expect(account.info[0].slot, BigInt.from(149694));
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct a slotHistory sysvar', () {
      final account = JsonParsedSlotHistorySysvar(
        info: JsonParsedSlotHistoryInfo(
          bits: '1111100000',
          nextSlot: BigInt.from(150104),
        ),
      );

      expect(account.type, 'slotHistory');
      expect(account.info.bits, '1111100000');
      expect(account.info.nextSlot, BigInt.from(150104));
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct a stakeHistory sysvar', () {
      final account = JsonParsedStakeHistorySysvar(
        info: [
          JsonParsedStakeHistoryEntry(
            epoch: BigInt.from(683),
            stakeHistory: JsonParsedStakeHistoryData(
              activating: BigInt.zero,
              deactivating: BigInt.zero,
              effective: BigInt.from(6561315032320),
            ),
          ),
          JsonParsedStakeHistoryEntry(
            epoch: BigInt.from(682),
            stakeHistory: JsonParsedStakeHistoryData(
              activating: BigInt.zero,
              deactivating: BigInt.zero,
              effective: BigInt.from(506560815032320),
            ),
          ),
        ],
      );

      expect(account.type, 'stakeHistory');
      expect(account.info, hasLength(2));
      expect(account.info[0].epoch, BigInt.from(683));
      expect(
        account.info[0].stakeHistory.effective,
        BigInt.from(6561315032320),
      );
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct a lastRestartSlot sysvar', () {
      final account = JsonParsedLastRestartSlotSysvar(
        info: JsonParsedLastRestartSlotInfo(lastRestartSlot: BigInt.zero),
      );

      expect(account.type, 'lastRestartSlot');
      expect(account.info.lastRestartSlot, BigInt.zero);
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can construct an epochRewards sysvar', () {
      final account = JsonParsedEpochRewardsSysvar(
        info: JsonParsedEpochRewardsInfo(
          distributedRewards: BigInt.from(100),
          distributionCompleteBlockHeight: BigInt.from(1000),
          totalRewards: BigInt.from(200),
        ),
      );

      expect(account.type, 'epochRewards');
      expect(account.info.distributedRewards, BigInt.from(100));
      expect(account.info.distributionCompleteBlockHeight, BigInt.from(1000));
      expect(account.info.totalRewards, BigInt.from(200));
      expect(account, isA<JsonParsedSysvarAccount>());
    });

    test('can discriminate via sealed class', () {
      final JsonParsedSysvarAccount account = JsonParsedClockSysvar(
        info: JsonParsedClockInfo(
          epoch: BigInt.zero,
          epochStartTimestamp: UnixTimestamp(BigInt.from(1704907181)),
          leaderScheduleEpoch: BigInt.one,
          slot: BigInt.from(90829),
          unixTimestamp: UnixTimestamp(BigInt.from(1704998009)),
        ),
      );

      switch (account) {
        case JsonParsedClockSysvar(:final info):
          expect(info.epoch, BigInt.zero);
        case JsonParsedEpochRewardsSysvar():
        case JsonParsedEpochScheduleSysvar():
        case JsonParsedFeesSysvar():
        case JsonParsedLastRestartSlotSysvar():
        case JsonParsedRecentBlockhashesSysvar():
        case JsonParsedRentSysvar():
        case JsonParsedSlotHashesSysvar():
        case JsonParsedSlotHistorySysvar():
        case JsonParsedStakeHistorySysvar():
          fail('Expected clock sysvar');
      }
    });

    test('sysvar models expose readable toString output', () {
      final clock = JsonParsedClockInfo(
        epoch: BigInt.zero,
        epochStartTimestamp: UnixTimestamp(BigInt.from(1704907181)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.from(90829),
        unixTimestamp: UnixTimestamp(BigInt.from(1704998009)),
      );
      const fees = JsonParsedFeesInfo(
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      final slotHistory = JsonParsedSlotHistoryInfo(
        bits: '1111100000',
        nextSlot: BigInt.from(150104),
      );
      final stakeHistory = JsonParsedStakeHistoryEntry(
        epoch: BigInt.from(683),
        stakeHistory: JsonParsedStakeHistoryData(
          activating: BigInt.zero,
          deactivating: BigInt.zero,
          effective: BigInt.from(6561315032320),
        ),
      );

      expect(clock.toString(), contains('leaderScheduleEpoch'));
      expect(fees.toString(), contains('lamportsPerSignature: 5000'));
      expect(slotHistory.toString(), contains('nextSlot: 150104'));
      expect(stakeHistory.toString(), contains('effective: 6561315032320'));
    });

    test('JsonParsedEpochScheduleInfo equality, hashCode, and toString', () {
      final info1 = JsonParsedEpochScheduleInfo(
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
        leaderScheduleSlotOffset: BigInt.from(432000),
        slotsPerEpoch: BigInt.from(432000),
        warmup: false,
      );
      final info2 = JsonParsedEpochScheduleInfo(
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
        leaderScheduleSlotOffset: BigInt.from(432000),
        slotsPerEpoch: BigInt.from(432000),
        warmup: false,
      );
      final info3 = JsonParsedEpochScheduleInfo(
        firstNormalEpoch: BigInt.one,
        firstNormalSlot: BigInt.zero,
        leaderScheduleSlotOffset: BigInt.from(432000),
        slotsPerEpoch: BigInt.from(432000),
        warmup: false,
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('firstNormalEpoch'));
    });

    test('JsonParsedFeesInfo equality, hashCode, and toString', () {
      const info1 = JsonParsedFeesInfo(
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      const info2 = JsonParsedFeesInfo(
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      const info3 = JsonParsedFeesInfo(
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('9999'),
        ),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('feeCalculator'));
    });

    test('JsonParsedFeeCalculator equality, hashCode, and toString', () {
      const fc1 = JsonParsedFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const fc2 = JsonParsedFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('5000'),
      );
      const fc3 = JsonParsedFeeCalculator(
        lamportsPerSignature: StringifiedBigInt('9999'),
      );

      expect(fc1, equals(fc2));
      expect(fc1.hashCode, equals(fc2.hashCode));
      expect(fc1 == fc3, isFalse);
      expect(fc1.toString(), contains('lamportsPerSignature'));
    });

    test('JsonParsedRentInfo equality, hashCode, and toString', () {
      const info1 = JsonParsedRentInfo(
        burnPercent: 50,
        exemptionThreshold: 2,
        lamportsPerByteYear: StringifiedBigInt('3480'),
      );
      const info2 = JsonParsedRentInfo(
        burnPercent: 50,
        exemptionThreshold: 2,
        lamportsPerByteYear: StringifiedBigInt('3480'),
      );
      const info3 = JsonParsedRentInfo(
        burnPercent: 100,
        exemptionThreshold: 2,
        lamportsPerByteYear: StringifiedBigInt('3480'),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('burnPercent'));
    });

    test('JsonParsedSlotHashEntry equality, hashCode, and toString', () {
      final entry1 = JsonParsedSlotHashEntry(
        hash: 'BAwX3h9EtGqBGnvXqgBoTZL19iHY8PKeCS9AVWFsVLQ8',
        slot: BigInt.from(149694),
      );
      final entry2 = JsonParsedSlotHashEntry(
        hash: 'BAwX3h9EtGqBGnvXqgBoTZL19iHY8PKeCS9AVWFsVLQ8',
        slot: BigInt.from(149694),
      );
      final entry3 = JsonParsedSlotHashEntry(
        hash: 'Different',
        slot: BigInt.from(149694),
      );

      expect(entry1, equals(entry2));
      expect(entry1.hashCode, equals(entry2.hashCode));
      expect(entry1 == entry3, isFalse);
      expect(entry1.toString(), contains('hash'));
    });

    test('JsonParsedSlotHistoryInfo equality, hashCode, and toString', () {
      final info1 = JsonParsedSlotHistoryInfo(
        bits: '1111100000',
        nextSlot: BigInt.from(150104),
      );
      final info2 = JsonParsedSlotHistoryInfo(
        bits: '1111100000',
        nextSlot: BigInt.from(150104),
      );
      final info3 = JsonParsedSlotHistoryInfo(
        bits: '0000011111',
        nextSlot: BigInt.from(150104),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('nextSlot'));
    });

    test('JsonParsedStakeHistoryEntry equality, hashCode, and toString', () {
      final entry1 = JsonParsedStakeHistoryEntry(
        epoch: BigInt.from(683),
        stakeHistory: JsonParsedStakeHistoryData(
          activating: BigInt.zero,
          deactivating: BigInt.zero,
          effective: BigInt.from(6561315032320),
        ),
      );
      final entry2 = JsonParsedStakeHistoryEntry(
        epoch: BigInt.from(683),
        stakeHistory: JsonParsedStakeHistoryData(
          activating: BigInt.zero,
          deactivating: BigInt.zero,
          effective: BigInt.from(6561315032320),
        ),
      );
      final entry3 = JsonParsedStakeHistoryEntry(
        epoch: BigInt.from(999),
        stakeHistory: JsonParsedStakeHistoryData(
          activating: BigInt.zero,
          deactivating: BigInt.zero,
          effective: BigInt.from(6561315032320),
        ),
      );

      expect(entry1, equals(entry2));
      expect(entry1.hashCode, equals(entry2.hashCode));
      expect(entry1 == entry3, isFalse);
      expect(entry1.toString(), contains('stakeHistory'));
    });

    test('JsonParsedStakeHistoryData equality, hashCode, and toString', () {
      final data1 = JsonParsedStakeHistoryData(
        activating: BigInt.zero,
        deactivating: BigInt.zero,
        effective: BigInt.from(6561315032320),
      );
      final data2 = JsonParsedStakeHistoryData(
        activating: BigInt.zero,
        deactivating: BigInt.zero,
        effective: BigInt.from(6561315032320),
      );
      final data3 = JsonParsedStakeHistoryData(
        activating: BigInt.one,
        deactivating: BigInt.zero,
        effective: BigInt.from(6561315032320),
      );

      expect(data1, equals(data2));
      expect(data1.hashCode, equals(data2.hashCode));
      expect(data1 == data3, isFalse);
      expect(data1.toString(), contains('effective'));
    });

    test('JsonParsedLastRestartSlotInfo equality, hashCode, and toString', () {
      final info1 = JsonParsedLastRestartSlotInfo(lastRestartSlot: BigInt.zero);
      final info2 = JsonParsedLastRestartSlotInfo(lastRestartSlot: BigInt.zero);
      final info3 = JsonParsedLastRestartSlotInfo(
        lastRestartSlot: BigInt.from(999),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('lastRestartSlot'));
    });

    test('JsonParsedEpochRewardsInfo equality, hashCode, and toString', () {
      final info1 = JsonParsedEpochRewardsInfo(
        distributedRewards: BigInt.from(100),
        distributionCompleteBlockHeight: BigInt.from(1000),
        totalRewards: BigInt.from(200),
      );
      final info2 = JsonParsedEpochRewardsInfo(
        distributedRewards: BigInt.from(100),
        distributionCompleteBlockHeight: BigInt.from(1000),
        totalRewards: BigInt.from(200),
      );
      final info3 = JsonParsedEpochRewardsInfo(
        distributedRewards: BigInt.from(500),
        distributionCompleteBlockHeight: BigInt.from(1000),
        totalRewards: BigInt.from(200),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('distributedRewards'));
    });

    test('JsonParsedRecentBlockhashEntry equality, hashCode, and toString', () {
      const entry1 = JsonParsedRecentBlockhashEntry(
        blockhash: Blockhash('Gy5GKD5p7UmUWF2BEm3TAUP4PSLTw9puSUbuoH5xPdzk'),
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      const entry2 = JsonParsedRecentBlockhashEntry(
        blockhash: Blockhash('Gy5GKD5p7UmUWF2BEm3TAUP4PSLTw9puSUbuoH5xPdzk'),
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );
      const entry3 = JsonParsedRecentBlockhashEntry(
        blockhash: Blockhash('FvNKRQk7TuFXVmXEM4XEubXdYREaeiWX56SL97taEhAQ'),
        feeCalculator: JsonParsedFeeCalculator(
          lamportsPerSignature: StringifiedBigInt('5000'),
        ),
      );

      expect(entry1, equals(entry2));
      expect(entry1.hashCode, equals(entry2.hashCode));
      expect(entry1 == entry3, isFalse);
      expect(entry1.toString(), contains('blockhash'));
    });

    test('JsonParsedClockInfo equality, hashCode, and toString', () {
      final info1 = JsonParsedClockInfo(
        epoch: BigInt.zero,
        epochStartTimestamp: UnixTimestamp(BigInt.from(1704907181)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.from(90829),
        unixTimestamp: UnixTimestamp(BigInt.from(1704998009)),
      );
      final info2 = JsonParsedClockInfo(
        epoch: BigInt.zero,
        epochStartTimestamp: UnixTimestamp(BigInt.from(1704907181)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.from(90829),
        unixTimestamp: UnixTimestamp(BigInt.from(1704998009)),
      );
      final info3 = JsonParsedClockInfo(
        epoch: BigInt.one,
        epochStartTimestamp: UnixTimestamp(BigInt.from(1704907181)),
        leaderScheduleEpoch: BigInt.one,
        slot: BigInt.from(90829),
        unixTimestamp: UnixTimestamp(BigInt.from(1704998009)),
      );

      expect(info1, equals(info2));
      expect(info1.hashCode, equals(info2.hashCode));
      expect(info1 == info3, isFalse);
      expect(info1.toString(), contains('epochStartTimestamp'));
    });
  });
}
