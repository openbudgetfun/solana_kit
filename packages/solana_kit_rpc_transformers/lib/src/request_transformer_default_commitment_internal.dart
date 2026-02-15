import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Applies a default commitment to the params list at the given position.
///
/// This function handles several cases:
/// - If no config object exists, it creates one with the default commitment.
/// - If the config object already has a commitment that is `finalized` or
///   `null`, it removes the commitment (since `finalized` is the server
///   default).
/// - If the config object has a different commitment, it leaves it as-is.
/// - If the override commitment is `finalized`, no default is applied (since
///   it is the server default).
List<Object?> applyDefaultCommitment({
  required String commitmentPropertyName,
  required List<Object?> params,
  required int optionsObjectPositionInParams,
  Commitment? overrideCommitment,
}) {
  final paramInTargetPosition = optionsObjectPositionInParams < params.length
      ? params[optionsObjectPositionInParams]
      : null;

  // Check that the param is either undefined or is a Map (not an array or
  // primitive).
  if (paramInTargetPosition == null ||
      (paramInTargetPosition is Map<String, Object?> &&
          paramInTargetPosition is! List)) {
    final configMap = paramInTargetPosition as Map<String, Object?>?;

    if (configMap != null && configMap.containsKey(commitmentPropertyName)) {
      // The config object already has a commitment set.
      final existingCommitment = configMap[commitmentPropertyName];

      if (existingCommitment == null ||
          existingCommitment == Commitment.finalized.name) {
        // Delete the commitment property; `finalized` is already the server
        // default.
        final nextParams = List<Object?>.of(params);
        final rest = Map<String, Object?>.of(configMap)
          ..remove(commitmentPropertyName);

        if (rest.isNotEmpty) {
          nextParams[optionsObjectPositionInParams] = rest;
        } else {
          if (optionsObjectPositionInParams == nextParams.length - 1) {
            nextParams.removeAt(nextParams.length - 1);
          } else {
            nextParams[optionsObjectPositionInParams] = null;
          }
        }
        return nextParams;
      }
    } else if (overrideCommitment != null &&
        overrideCommitment != Commitment.finalized) {
      // Apply the default commitment.
      final nextParams = List<Object?>.of(params);
      // Ensure the list is long enough.
      while (nextParams.length <= optionsObjectPositionInParams) {
        nextParams.add(null);
      }
      nextParams[optionsObjectPositionInParams] = <String, Object?>{
        if (configMap != null) ...configMap,
        commitmentPropertyName: overrideCommitment.name,
      };
      return nextParams;
    }
  }

  return params;
}
