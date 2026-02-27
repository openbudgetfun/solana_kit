// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  final clock = SysvarClock(
    slot: BigInt.from(100),
    epochStartTimestamp: BigInt.from(50),
    epoch: BigInt.from(2),
    leaderScheduleEpoch: BigInt.from(2),
    unixTimestamp: BigInt.from(1_700_000_000),
  );

  final codec = getSysvarClockCodec();
  final encoded = codec.encode(clock);
  final decoded = codec.decode(encoded);

  print('Clock bytes length: ${encoded.length}');
  print('Decoded slot: ${decoded.slot}');
}
