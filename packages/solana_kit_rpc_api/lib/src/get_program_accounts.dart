import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getProgramAccounts` RPC method.
class GetProgramAccountsConfig {
  /// Creates a new [GetProgramAccountsConfig].
  const GetProgramAccountsConfig({
    this.commitment,
    this.encoding,
    this.dataSlice,
    this.filters,
    this.minContextSlot,
    this.withContext,
  });

  /// Fetch the details of the accounts as of the highest slot that has
  /// reached this level of commitment.
  final Commitment? commitment;

  /// Determines how the accounts' data should be encoded in the response.
  final String? encoding;

  /// Define which slice of the accounts' data to return.
  final DataSlice? dataSlice;

  /// Limits results to those that match all of these filters.
  final List<Object>? filters;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;

  /// Wraps the result in an RpcResponse when `true`.
  final bool? withContext;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding;
    if (dataSlice != null) {
      json['dataSlice'] = {
        'offset': dataSlice!.offset,
        'length': dataSlice!.length,
      };
    }
    if (filters != null) json['filters'] = filters;
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    if (withContext != null) json['withContext'] = withContext;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getProgramAccounts`.
List<Object?> getProgramAccountsParams(
  Address program, [
  GetProgramAccountsConfig? config,
]) {
  return [program.value, if (config != null) config.toJson()];
}
