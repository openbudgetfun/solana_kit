import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:solana_kit_rpc_transformers/src/request_transformer_bigint_downcast.dart';
import 'package:solana_kit_rpc_transformers/src/request_transformer_default_commitment.dart';
import 'package:solana_kit_rpc_transformers/src/request_transformer_integer_overflow.dart';
import 'package:solana_kit_rpc_transformers/src/request_transformer_options_object_position_config.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Configuration for the default request transformer.
class RequestTransformerConfig {
  /// Creates a new [RequestTransformerConfig].
  const RequestTransformerConfig({
    this.defaultCommitment,
    this.onIntegerOverflow,
  });

  /// An optional [Commitment] value to use as the default when none is
  /// supplied by the caller.
  final Commitment? defaultCommitment;

  /// An optional function that will be called whenever a [BigInt] input
  /// exceeds that which can be expressed using JavaScript numbers.
  ///
  /// This is used in the default Solana RPC API to throw an exception rather
  /// than to allow truncated values to propagate through a program.
  final IntegerOverflowHandler? onIntegerOverflow;
}

/// Returns the default request transformer for the Solana RPC API.
///
/// Under the hood, this function composes multiple
/// [RpcRequestTransformer]s together: the integer overflow checker,
/// the BigInt downcast transformer, and the default commitment transformer.
RpcRequestTransformer getDefaultRequestTransformerForSolanaRpc([
  RequestTransformerConfig? config,
]) {
  final handleIntegerOverflow = config?.onIntegerOverflow;
  return (RpcRequest<Object?> request) {
    var result = request;

    // Step 1: Check for integer overflow (if handler provided).
    if (handleIntegerOverflow != null) {
      result = getIntegerOverflowRequestTransformer(handleIntegerOverflow)(
        result,
      );
    }

    // Step 2: Downcast BigInt values to int.
    result = getBigIntDowncastRequestTransformer()(result);

    // Step 3: Apply default commitment.
    result = getDefaultCommitmentRequestTransformer(
      optionsObjectPositionByMethod: OPTIONS_OBJECT_POSITION_BY_METHOD,
      defaultCommitment: config?.defaultCommitment,
    )(result);

    return result;
  };
}
