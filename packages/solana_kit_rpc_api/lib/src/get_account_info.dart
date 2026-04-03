import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getAccountInfo` RPC method.
class GetAccountInfoConfig {
  /// Creates a new [GetAccountInfoConfig].
  const GetAccountInfoConfig({
    this.commitment,
    this.encoding,
    this.dataSlice,
    this.minContextSlot,
  });

  /// Fetch the details of the account as of the highest slot that has reached
  /// this level of commitment.
  final Commitment? commitment;

  /// Determines how the account data should be encoded in the response.
  final AccountEncoding? encoding;

  /// Define which slice of the account's data to return.
  ///
  /// Only available for `'base58'`, `'base64'`, and `'base64+zstd'` encodings.
  final DataSlice? dataSlice;

  /// Prevents accessing stale data by enforcing that the RPC node has
  /// processed transactions up to this slot.
  final Slot? minContextSlot;

  /// Converts this config to a JSON-RPC params map.
  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (commitment != null) json['commitment'] = commitment!.name;
    if (encoding != null) json['encoding'] = encoding!.toJson();
    if (dataSlice != null) {
      json['dataSlice'] = {
        'offset': dataSlice!.offset,
        'length': dataSlice!.length,
      };
    }
    if (minContextSlot != null) json['minContextSlot'] = minContextSlot;
    return json;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetAccountInfoConfig &&
          runtimeType == other.runtimeType &&
          commitment == other.commitment &&
          encoding == other.encoding &&
          dataSlice == other.dataSlice &&
          minContextSlot == other.minContextSlot;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    commitment,
    encoding,
    dataSlice,
    minContextSlot,
  );

  @override
  String toString() =>
      'GetAccountInfoConfig(commitment: $commitment, encoding: $encoding, '
      'dataSlice: $dataSlice, minContextSlot: $minContextSlot)';
}

/// Builds the JSON-RPC params list for `getAccountInfo`.
List<Object?> getAccountInfoParams(
  Address address, [
  GetAccountInfoConfig? config,
]) {
  return [address.value, if (config != null) config.toJson()];
}
