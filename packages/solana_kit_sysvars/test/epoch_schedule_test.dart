import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('epoch schedule', () {
    test('decode', () {
      // From TS test: epoch-schedule-test.ts
      final epochScheduleState = Uint8List.fromList([
        // slotsPerEpoch
        16, 39, 0, 0, 0, 0, 0, 0,
        // leaderScheduleSlotOffset
        134, 74, 2, 0, 0, 0, 0, 0,
        // warmup
        1,
        // firstNormalEpoch
        38, 2, 0, 0, 0, 0, 0, 0,
        // firstNormalSlot
        128, 147, 220, 20, 0, 0, 0, 0,
      ]);

      final result = getSysvarEpochScheduleCodec().decode(epochScheduleState);
      expect(result.slotsPerEpoch, equals(BigInt.from(10000)));
      expect(result.leaderScheduleSlotOffset, equals(BigInt.from(150150)));
      expect(result.warmup, isTrue);
      expect(result.firstNormalEpoch, equals(BigInt.from(550)));
      expect(result.firstNormalSlot, equals(BigInt.from(350000000)));
    });

    test('encode roundtrip', () {
      final schedule = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(10000),
        leaderScheduleSlotOffset: BigInt.from(150150),
        warmup: true,
        firstNormalEpoch: BigInt.from(550),
        firstNormalSlot: BigInt.from(350000000),
      );

      final codec = getSysvarEpochScheduleCodec();
      final encoded = codec.encode(schedule);
      final decoded = codec.decode(encoded);

      expect(decoded.slotsPerEpoch, equals(schedule.slotsPerEpoch));
      expect(
        decoded.leaderScheduleSlotOffset,
        equals(schedule.leaderScheduleSlotOffset),
      );
      expect(decoded.warmup, equals(schedule.warmup));
      expect(decoded.firstNormalEpoch, equals(schedule.firstNormalEpoch));
      expect(decoded.firstNormalSlot, equals(schedule.firstNormalSlot));
    });

    test('encoder has correct fixed size', () {
      final encoder = getSysvarEpochScheduleEncoder();
      expect(encoder.fixedSize, equals(sysvarEpochScheduleSize));
      expect(encoder.fixedSize, equals(33));
      expect(isFixedSize(encoder), isTrue);
    });

    test('decode with warmup false', () {
      final schedule = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(432000),
        leaderScheduleSlotOffset: BigInt.from(432000),
        warmup: false,
        firstNormalEpoch: BigInt.zero,
        firstNormalSlot: BigInt.zero,
      );

      final codec = getSysvarEpochScheduleCodec();
      final encoded = codec.encode(schedule);
      final decoded = codec.decode(encoded);

      expect(decoded.warmup, isFalse);
    });

    test('SysvarEpochSchedule equality', () {
      final a = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(10000),
        leaderScheduleSlotOffset: BigInt.from(150150),
        warmup: true,
        firstNormalEpoch: BigInt.from(550),
        firstNormalSlot: BigInt.from(350000000),
      );
      final b = SysvarEpochSchedule(
        slotsPerEpoch: BigInt.from(10000),
        leaderScheduleSlotOffset: BigInt.from(150150),
        warmup: true,
        firstNormalEpoch: BigInt.from(550),
        firstNormalSlot: BigInt.from(350000000),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
