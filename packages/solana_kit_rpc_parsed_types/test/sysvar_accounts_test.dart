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
  });
}
