import 'package:meta/meta.dart';
import 'package:solana_kit_rpc_types/src/blockhash.dart';

/// Typed value returned by `getLatestBlockhash`.
@immutable
class LatestBlockhashValue {
  /// Creates a [LatestBlockhashValue].
  const LatestBlockhashValue({
    required this.blockhash,
    required this.lastValidBlockHeight,
  });

  /// The latest blockhash.
  final Blockhash blockhash;

  /// The last block height at which the blockhash remains valid.
  final BigInt lastValidBlockHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatestBlockhashValue &&
          blockhash == other.blockhash &&
          lastValidBlockHeight == other.lastValidBlockHeight;

  @override
  int get hashCode => Object.hash(blockhash, lastValidBlockHeight);

  @override
  String toString() =>
      'LatestBlockhashValue(blockhash: $blockhash, '
      'lastValidBlockHeight: $lastValidBlockHeight)';
}
