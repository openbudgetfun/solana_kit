/// Builds the JSON-RPC params list for `getRecentPrioritizationFees`.
List<Object?> getRecentPrioritizationFeesParams([List<Address>? addresses]) {
  return [
    if (addresses != null) [for (final address in addresses) address.value],
  ];
}
