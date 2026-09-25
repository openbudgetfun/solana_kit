import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getLeaderSchedule` RPC method.
class GetLeaderScheduleConfig {
  /// Creates a new [GetLeaderScheduleConfig].
  const GetLeaderScheduleConfig({this.commitment, this.identity});

  /// Fetch the leader schedule as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// Only return results for this validator identity.
  final Address? identity;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (identity != null) json['identity'] = identity!.value;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getLeaderSchedule`.
List<Object?> getLeaderScheduleParams([
  Slot? slot,
  GetLeaderScheduleConfig? config,
]) {
  return [slot, if (config != null) config.toJson()];
}
