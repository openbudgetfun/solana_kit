/// Builds the JSON-RPC params list for `getRecentPerformanceSamples`.
List<Object?> getRecentPerformanceSamplesParams([int? limit]) {
  return [if (limit != null) limit];
}
