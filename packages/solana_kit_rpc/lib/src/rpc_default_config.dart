import 'package:solana_kit_rpc/src/rpc_integer_overflow_error.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Default configuration for the Solana RPC API.
///
/// When you create `Rpc` instances with custom transports but otherwise the
/// default RPC API behaviours, use this.
///
/// ```dart
/// final myCustomRpc = createRpc(
///   RpcConfig(
///     api: createSolanaRpcApiAdapter(defaultRpcConfig),
///     transport: myCustomTransport,
///   ),
/// );
/// ```
final SolanaRpcApiConfig defaultRpcConfig = SolanaRpcApiConfig(
  defaultCommitment: Commitment.confirmed,
  onIntegerOverflow: (request, keyPath, value) {
    throw createSolanaJsonRpcIntegerOverflowError(
      request.methodName,
      keyPath,
      value,
    );
  },
);
