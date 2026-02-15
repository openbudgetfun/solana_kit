import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/src/request_transformer_default_commitment_internal.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Creates a transformer that adds the provided default commitment to the
/// configuration object of the request when applicable.
///
/// For the `sendTransaction` method, the commitment property name is
/// `preflightCommitment` instead of `commitment`.
RpcRequestTransformer getDefaultCommitmentRequestTransformer({
  required Map<String, int> optionsObjectPositionByMethod,
  Commitment? defaultCommitment,
}) {
  return (RpcRequest<Object?> request) {
    final params = request.params;

    // We only apply default commitment to list parameters.
    if (params is! List) {
      return request;
    }

    // Find the position of the options object in the parameters and abort if
    // not found.
    final optionsObjectPositionInParams =
        optionsObjectPositionByMethod[request.methodName];
    if (optionsObjectPositionInParams == null) {
      return request;
    }

    return RpcRequest(
      methodName: request.methodName,
      params: applyDefaultCommitment(
        commitmentPropertyName: request.methodName == 'sendTransaction'
            ? 'preflightCommitment'
            : 'commitment',
        optionsObjectPositionInParams: optionsObjectPositionInParams,
        overrideCommitment: defaultCommitment,
        params: List<Object?>.of(params),
      ),
    );
  };
}
