import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getVoteAccounts` RPC method.
class GetVoteAccountsConfig {
  /// Creates a new [GetVoteAccountsConfig].
  const GetVoteAccountsConfig({
    this.commitment,
    this.delinquentSlotDistance,
    this.keepUnstakedDelinquents,
    this.votePubkey,
  });

  /// Fetch vote account details as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// The number of slots behind the tip that a validator must fall to be
  /// considered delinquent.
  final BigInt? delinquentSlotDistance;

  /// Return delinquent validators even if they are unstaked.
  final bool? keepUnstakedDelinquents;

  /// Only return results for this vote account address.
  final Address? votePubkey;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (delinquentSlotDistance != null) {
      json['delinquentSlotDistance'] = delinquentSlotDistance;
    }
    if (keepUnstakedDelinquents != null) {
      json['keepUnstakedDelinquents'] = keepUnstakedDelinquents;
    }
    if (votePubkey != null) json['votePubkey'] = votePubkey!.value;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getVoteAccounts`.
List<Object?> getVoteAccountsParams([GetVoteAccountsConfig? config]) {
  return [if (config != null) config.toJson()];
}
