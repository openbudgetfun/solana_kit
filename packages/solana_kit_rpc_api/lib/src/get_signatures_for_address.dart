import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getSignaturesForAddress` RPC method.
class GetSignaturesForAddressConfig {
  /// Creates a new [GetSignaturesForAddressConfig].
  const GetSignaturesForAddressConfig({
    this.before,
    this.commitment,
    this.limit,
    this.minContextSlot,
    this.until,
  });

  /// Start the search from before, but excluding, this signature.
  final Signature? before;

  /// Fetch the signatures as of the highest slot that has reached this level
  /// of commitment. Note: `processed` is not supported.
  final Commitment? commitment;

  /// Maximum transaction signatures to return (between 1 and 1,000).
  final int? limit;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;

  /// Search, back in time, until this transaction signature.
  final Signature? until;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (before != null) json['before'] = before!.value;
    if (commitment != null) json['commitment'] = commitment!.name;
    if (limit != null) json['limit'] = limit;
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    if (until != null) json['until'] = until!.value;
    return json;
  }
}

/// Builds the JSON-RPC params list for `getSignaturesForAddress`.
List<Object?> getSignaturesForAddressParams(
  Address address, [
  GetSignaturesForAddressConfig? config,
]) {
  return [address.value, if (config != null) config.toJson()];
}
