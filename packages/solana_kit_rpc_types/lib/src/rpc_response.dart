import 'package:solana_kit_rpc_types/src/typed_numbers.dart';

/// Context information included with every RPC response.
class RpcResponseContext {
  /// Creates the RPC response context for the supplied [slot].
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
  /// Creates a Solana RPC response wrapping [context] and [value].
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

/// Type-guards [notification] as a [SolanaRpcResponse] envelope.
///
/// Returns `true` when [notification] is a [SolanaRpcResponse] envelope, so
/// callers can surface `context.slot` and `value` without a cast.
///
/// This mirrors the upstream `@solana/rpc-types` `isSolanaRpcResponse` helper
/// added in @solana/kit v7.0.0. The upstream version duck-types `context.slot`
/// as a `bigint`; in Dart the `SolanaRpcResponse` class already carries a typed
/// [RpcResponseContext.slot] (`Slot` = [BigInt]), so a reified type test is
/// sufficient and idiomatic.
///
/// ```dart
/// import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
///
/// Object? lift<T>(T notification) {
///   if (notification is SolanaRpcResponse<Object?>) {
///     return (notification.context.slot, notification.value);
///   }
///   return notification;
/// }
/// ```
///
/// Added in @solana/kit v7.0.0.
bool isSolanaRpcResponse(Object? notification) {
  return notification is SolanaRpcResponse<Object?>;
}
