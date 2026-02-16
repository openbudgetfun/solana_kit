import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('clock', () {
    test('decode', () {
      // From TS test: clock-test.ts
      final clockState = Uint8List.fromList([
        // slot
        119, 233, 246, 16, 0, 0, 0, 0,
        // epochStartTimestamp
        246, 255, 255, 255, 255, 255, 255, 255,
        // epoch
        4, 0, 0, 0, 0, 0, 0, 0,
        // leaderScheduleEpoch
        0, 0, 0, 0, 0, 0, 0, 0,
        // unixTimestamp
        224, 177, 255, 255, 255, 255, 255, 255,
      ]);

      final result = getSysvarClockCodec().decode(clockState);
      expect(result.slot, equals(BigInt.from(284617079)));
      expect(result.epochStartTimestamp, equals(BigInt.from(-10)));
      expect(result.epoch, equals(BigInt.from(4)));
      expect(result.leaderScheduleEpoch, equals(BigInt.zero));
      expect(result.unixTimestamp, equals(BigInt.from(-20000)));
    });

    test('encode roundtrip', () {
      final clock = SysvarClock(
        slot: BigInt.from(284617079),
        epochStartTimestamp: BigInt.from(-10),
        epoch: BigInt.from(4),
        leaderScheduleEpoch: BigInt.zero,
        unixTimestamp: BigInt.from(-20000),
      );

      final codec = getSysvarClockCodec();
      final encoded = codec.encode(clock);
      final decoded = codec.decode(encoded);

      expect(decoded.slot, equals(clock.slot));
      expect(decoded.epochStartTimestamp, equals(clock.epochStartTimestamp));
      expect(decoded.epoch, equals(clock.epoch));
      expect(decoded.leaderScheduleEpoch, equals(clock.leaderScheduleEpoch));
      expect(decoded.unixTimestamp, equals(clock.unixTimestamp));
    });

    test('encoder has correct fixed size', () {
      final encoder = getSysvarClockEncoder();
      expect(encoder.fixedSize, equals(sysvarClockSize));
      expect(encoder.fixedSize, equals(40));
      expect(isFixedSize(encoder), isTrue);
    });

    test('decoder has correct fixed size', () {
      final decoder = getSysvarClockDecoder();
      expect(decoder.fixedSize, equals(sysvarClockSize));
      expect(isFixedSize(decoder), isTrue);
    });

    test('codec has correct fixed size', () {
      final codec = getSysvarClockCodec();
      expect(codec.fixedSize, equals(sysvarClockSize));
      expect(isFixedSize(codec), isTrue);
    });

    test('SysvarClock equality', () {
      final a = SysvarClock(
        slot: BigInt.from(100),
        epochStartTimestamp: BigInt.from(200),
        epoch: BigInt.from(3),
        leaderScheduleEpoch: BigInt.from(4),
        unixTimestamp: BigInt.from(500),
      );
      final b = SysvarClock(
        slot: BigInt.from(100),
        epochStartTimestamp: BigInt.from(200),
        epoch: BigInt.from(3),
        leaderScheduleEpoch: BigInt.from(4),
        unixTimestamp: BigInt.from(500),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
