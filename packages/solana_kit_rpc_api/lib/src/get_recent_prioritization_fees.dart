import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Builds the JSON-RPC params list for `getRecentPrioritizationFees`.
List<Object?> getRecentPrioritizationFeesParams([List<Address>? addresses]) {
  return [
    if (addresses != null) [for (final address in addresses) address.value],
  ];
}
