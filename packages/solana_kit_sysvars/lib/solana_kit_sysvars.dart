/// Typed sysvar models, addresses, and codecs for the Solana Kit Dart SDK.
///
/// Use this library when you need access to built-in Solana cluster state
/// accounts such as `Clock`, `Rent`, `EpochSchedule`, or `StakeHistory`.
///
/// <!-- {=docsSysvarSection} -->
///
/// ## Work with sysvar codecs and addresses
///
/// Use `solana_kit_sysvars` when you need typed access to built-in cluster state
/// accounts such as `Clock`, `Rent`, or `EpochSchedule`.
///
/// ```dart
/// import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
///
/// void main() {
///   final clock = SysvarClock(
///     slot: BigInt.from(100),
///     epochStartTimestamp: BigInt.from(50),
///     epoch: BigInt.from(2),
///     leaderScheduleEpoch: BigInt.from(2),
///     unixTimestamp: BigInt.from(1_700_000_000),
///   );
///
///   final encoded = getSysvarClockCodec().encode(clock);
///   final decoded = getSysvarClockCodec().decode(encoded);
///
///   print(sysvarClockAddress.value);
///   print(decoded.slot);
/// }
/// ```
///
/// These helpers keep sysvar access strongly typed and let you test sysvar layouts
/// without depending on live RPC responses.
///
/// <!-- {/docsSysvarSection} -->
library;

export 'src/clock.dart';
export 'src/epoch_rewards.dart';
export 'src/epoch_schedule.dart';
export 'src/last_restart_slot.dart';
export 'src/recent_blockhashes.dart';
export 'src/rent.dart';
export 'src/slot_hashes.dart';
export 'src/slot_history.dart';
export 'src/stake_history.dart';
export 'src/sysvar.dart';
