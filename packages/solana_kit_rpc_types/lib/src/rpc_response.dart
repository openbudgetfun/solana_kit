import 'package:solana_kit_rpc_types/src/typed_numbers.dart';

/// Context information included with every RPC response.
class RpcResponseContext {
  const RpcResponseContext({required this.slot});

  /// The slot at which the response was generated.
  final Slot slot;
}

/// A standard Solana RPC response wrapper containing a [context] and a
/// [value].
class SolanaRpcResponse<TValue> {
  const SolanaRpcResponse({required this.context, required this.value});

  /// The context in which this response was generated.
  final RpcResponseContext context;

  /// The response value.
  final TValue value;
}
