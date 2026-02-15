import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getLargestAccounts` RPC method.
class GetLargestAccountsConfig {
  /// Creates a new [GetLargestAccountsConfig].
  const GetLargestAccountsConfig({this.commitment, this.filter});

  /// Fetch the largest accounts as of the highest slot that has reached this
  /// level of commitment.
  final Commitment? commitment;

  /// Filter results by account type: `'circulating'` or `'nonCirculating'`.
  final String? filter;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (filter != null) json['filter'] = filter;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getLargestAccounts`.
List<Object?> getLargestAccountsParams([GetLargestAccountsConfig? config]) {
  return [if (config != null) config.toJson()];
}
