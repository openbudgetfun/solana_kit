import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the `getTokenAccountsByDelegate` RPC method.
class GetTokenAccountsByDelegateConfig {
  /// Creates a new [GetTokenAccountsByDelegateConfig].
  const GetTokenAccountsByDelegateConfig({
    this.commitment,
    this.encoding,
    this.dataSlice,
    this.minContextSlot,
  });

  /// Fetch the details of the accounts as of the highest slot that has
  /// reached this level of commitment.
  final Commitment? commitment;

  /// Determines how the accounts' data should be encoded.
  final String? encoding;

  /// Define which slice of the accounts' data to return.
  final DataSlice? dataSlice;

  /// Prevents accessing stale data.
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

/// A filter for token accounts by mint address.
class TokenAccountMintFilter {
  /// Creates a new [TokenAccountMintFilter].
  const TokenAccountMintFilter({required this.mint});

  /// The mint address to filter by.
  final Address mint;

  /// Converts to a JSON map.
  Map<String, Object?> toJson() => {'mint': mint.value};
}

/// A filter for token accounts by program ID.
class TokenAccountProgramIdFilter {
  /// Creates a new [TokenAccountProgramIdFilter].
  const TokenAccountProgramIdFilter({required this.programId});

  /// The token program address to filter by.
  final Address programId;

  /// Converts to a JSON map.
  Map<String, Object?> toJson() => {'programId': programId.value};
}

/// Builds the JSON-RPC params list for `getTokenAccountsByDelegate`.
List<Object?> getTokenAccountsByDelegateParams(
  Address delegate,
  Map<String, Object?> filter, [
  GetTokenAccountsByDelegateConfig? config,
]) {
  return [delegate.value, filter, if (config != null) config.toJson()];
}
