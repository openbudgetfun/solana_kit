import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';

import 'package:solana_kit_rpc_transformers/src/response_transformer_allowed_numeric_values.dart';
import 'package:solana_kit_rpc_transformers/src/response_transformer_bigint_upcast.dart';
import 'package:solana_kit_rpc_transformers/src/response_transformer_result.dart';
import 'package:solana_kit_rpc_transformers/src/response_transformer_throw_solana_error.dart';
import 'package:solana_kit_rpc_transformers/src/tree_traversal.dart';

/// Configuration for the default response transformer.
class ResponseTransformerConfig {
  /// Creates a new [ResponseTransformerConfig].
  const ResponseTransformerConfig({this.allowedNumericKeyPaths});

  /// An optional map from the name of an API method to a list of [KeyPath]s
  /// pointing to values in the response that should materialize in the
  /// application as [int] instead of [BigInt].
  final AllowedNumericKeypaths? allowedNumericKeyPaths;
}

/// Returns the default response transformer for the Solana RPC API.
///
/// Under the hood, this function composes multiple response transformers
/// together: the throw-on-error transformer, the result extractor, and
/// the BigInt upcast transformer.
RpcResponseTransformer<Object?> getDefaultResponseTransformerForSolanaRpc([
  ResponseTransformerConfig? config,
]) {
  return (Object? response, RpcRequest<Object?> request) {
    final methodName = request.methodName;
    final keyPaths =
        config?.allowedNumericKeyPaths != null && methodName.isNotEmpty
        ? config!.allowedNumericKeyPaths![methodName]
        : null;

    // Step 1: Throw on error.
    var result = getThrowSolanaErrorResponseTransformer()(response, request);

    // Step 2: Extract result.
    result = getResultResponseTransformer()(result, request);

    // Step 3: BigInt upcast.
    result = getBigIntUpcastResponseTransformer(keyPaths ?? [])(
      result,
      request,
    );

    return result;
  };
}

/// Returns the default response transformer for the Solana RPC Subscriptions
/// API.
///
/// Under the hood, this function composes the BigInt upcast transformer.
RpcResponseTransformer<Object?>
getDefaultResponseTransformerForSolanaRpcSubscriptions([
  ResponseTransformerConfig? config,
]) {
  return (Object? response, RpcRequest<Object?> request) {
    final methodName = request.methodName;
    final keyPaths =
        config?.allowedNumericKeyPaths != null && methodName.isNotEmpty
        ? config!.allowedNumericKeyPaths![methodName]
        : null;

    return getBigIntUpcastResponseTransformer(keyPaths ?? [])(
      response,
      request,
    );
  };
}
