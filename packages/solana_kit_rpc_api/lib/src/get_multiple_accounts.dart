import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getMultipleAccounts` RPC method.
class GetMultipleAccountsConfig {
  /// Creates a new [GetMultipleAccountsConfig].
  const GetMultipleAccountsConfig({
    this.commitment,
    this.encoding,
    this.dataSlice,
    this.minContextSlot,
  });

  /// Fetch the details of the accounts as of the highest slot that has
  /// reached this level of commitment.
  final Commitment? commitment;

  /// Determines how the accounts' data should be encoded in the response.
  final String? encoding;

  /// Define which slice of the accounts' data to return.
  final DataSlice? dataSlice;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;

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
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getMultipleAccounts`.
List<Object?> getMultipleAccountsParams(
  List<Address> addresses, [
  GetMultipleAccountsConfig? config,
]) {
  return [
    [for (final address in addresses) address.value],
    if (config != null) config.toJson(),
  ];
}
