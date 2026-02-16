import 'package:solana_kit_rpc_subscriptions/src/rpc_integer_overflow_error.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Default configuration for Solana RPC subscriptions.
///
/// This configuration applies sensible defaults such as:
/// - A default commitment of `Commitment.confirmed`.
/// - An integer overflow handler that throws a `SolanaError`.
class DefaultRpcSubscriptionsConfig {
  /// The default commitment level for subscriptions.
  static const Commitment defaultCommitment = Commitment.confirmed;

  /// The default handler for integer overflow.
  ///
  /// Throws a `SolanaError` with the integer overflow error code.
  static Never onIntegerOverflow(
    String methodName,
    List<Object> keyPath,
    BigInt value,
  ) {
    throw createSolanaJsonRpcIntegerOverflowError(methodName, keyPath, value);
  }
}
