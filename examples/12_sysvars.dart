// ignore_for_file: avoid_print
/// Example 12: Sysvar addresses and codec round-trips.
///
/// Sysvars are built-in Solana accounts that expose cluster state such as the
/// current clock, rent parameters, and epoch schedule.  This example shows
/// their well-known addresses and how to encode/decode their layouts without
/// hitting the network.
///
/// Run:
///   dart examples/12_sysvars.dart
library;

import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';

void main() {
  // ── 1. Well-known sysvar addresses ────────────────────────────────────────
  print('Clock   sysvar: ${sysvarClockAddress.value}');
  print('Rent    sysvar: ${sysvarRentAddress.value}');
  print('Epoch schedule: ${sysvarEpochScheduleAddress.value}');
  print('Recent hashes : ${sysvarRecentBlockhashesAddress.value}');
  print('Stake history : ${sysvarStakeHistoryAddress.value}');
  print('Instructions  : ${sysvarInstructionsAddress.value}');

  // ── 2. Clock codec round-trip ─────────────────────────────────────────────
  final clock = SysvarClock(
    slot: BigInt.from(250_000_000),
    epochStartTimestamp: BigInt.from(1_700_000_000),
    epoch: BigInt.from(580),
    leaderScheduleEpoch: BigInt.from(581),
    unixTimestamp: BigInt.from(1_710_000_000),
  );

  final clockCodec = getSysvarClockCodec();
  final encoded = clockCodec.encode(clock);
  final decoded = clockCodec.decode(encoded);

  print('\nClock round-trip:');
  print('  slot              : ${decoded.slot}');
  print('  epoch             : ${decoded.epoch}');
  print('  unix timestamp    : ${decoded.unixTimestamp}');
  print('  encoded size      : ${encoded.length} bytes');

  // ── 3. Rent codec round-trip ──────────────────────────────────────────────
  final rent = SysvarRent(
    lamportsPerByteYear: Lamports(BigInt.from(3480)),
    exemptionThreshold: 2.0,
    burnPercent: 50,
  );

  final rentCodec = getSysvarRentCodec();
  final rentEncoded = rentCodec.encode(rent);
  final rentDecoded = rentCodec.decode(rentEncoded);

  print('\nRent round-trip:');
  print('  lamports/byte/year : ${rentDecoded.lamportsPerByteYear}');
  print('  exemption threshold: ${rentDecoded.exemptionThreshold}');
  print('  burn percent       : ${rentDecoded.burnPercent}');
  print('  encoded size       : ${rentEncoded.length} bytes');

  // ── 4. EpochSchedule codec round-trip ─────────────────────────────────────
  final epochSchedule = SysvarEpochSchedule(
    slotsPerEpoch: BigInt.from(432_000),
    leaderScheduleSlotOffset: BigInt.from(432_000),
    warmup: true,
    firstNormalEpoch: BigInt.from(14),
    firstNormalSlot: BigInt.from(524_256),
  );

  final epochCodec = getSysvarEpochScheduleCodec();
  final epochEncoded = epochCodec.encode(epochSchedule);
  final epochDecoded = epochCodec.decode(epochEncoded);

  print('\nEpochSchedule round-trip:');
  print('  slots per epoch    : ${epochDecoded.slotsPerEpoch}');
  print('  first normal epoch : ${epochDecoded.firstNormalEpoch}');
  print('  encoded size       : ${epochEncoded.length} bytes');
}
