// ignore_for_file: public_member_api_docs
import 'package:solana_kit_rpc_types/src/typed_numbers.dart';

/// Context information included with every RPC response.
class RpcResponseContext {
  const RpcResponseContext({required this.slot});

  /// The slot at which the response was generated.
  final Slot slot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RpcResponseContext &&
          runtimeType == other.runtimeType &&
          slot == other.slot;

  @override
  int get hashCode => Object.hash(runtimeType, slot);

  @override
  String toString() => 'RpcResponseContext(slot: $slot)';
}

/// A standard Solana RPC response wrapper containing a [context] and a
/// [value].
class SolanaRpcResponse<TValue> {
  const SolanaRpcResponse({required this.context, required this.value});

  /// The context in which this response was generated.
  final RpcResponseContext context;

  /// The response value.
  final TValue value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolanaRpcResponse<TValue> &&
          runtimeType == other.runtimeType &&
          context == other.context &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, context, value);

  @override
  String toString() => 'SolanaRpcResponse(context: $context, value: $value)';
}
