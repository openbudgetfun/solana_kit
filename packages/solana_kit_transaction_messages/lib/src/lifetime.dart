import 'package:meta/meta.dart';

/// Sealed class representing a lifetime constraint for a transaction message.
@immutable
sealed class LifetimeConstraint {
  const LifetimeConstraint();
}

/// A constraint which, when applied to a transaction message, makes that
/// transaction message eligible to land on the network. The transaction message
/// will continue to be eligible to land until the network considers the
/// [blockhash] to be expired.
@immutable
class BlockhashLifetimeConstraint extends LifetimeConstraint {
  /// Creates a [BlockhashLifetimeConstraint] with the given [blockhash] and
  /// [lastValidBlockHeight].
  const BlockhashLifetimeConstraint({
    required this.blockhash,
    required this.lastValidBlockHeight,
  });

  /// A recent blockhash observed by the transaction proposer.
  final String blockhash;

  /// The block height beyond which the network will consider the blockhash
  /// to be too old.
  final BigInt lastValidBlockHeight;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockhashLifetimeConstraint &&
          blockhash == other.blockhash &&
          lastValidBlockHeight == other.lastValidBlockHeight;

  @override
  int get hashCode => Object.hash(blockhash, lastValidBlockHeight);
}

/// A constraint which, when applied to a transaction message, makes that
/// transaction message eligible to land on the network. The transaction message
/// will continue to be eligible to land until the nonce value changes.
@immutable
class DurableNonceLifetimeConstraint extends LifetimeConstraint {
  /// Creates a [DurableNonceLifetimeConstraint] with the given [nonce].
  const DurableNonceLifetimeConstraint({required this.nonce});

  /// A value contained in the related nonce account at the time the
  /// transaction was prepared.
  final String nonce;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurableNonceLifetimeConstraint && nonce == other.nonce;

  @override
  int get hashCode => nonce.hashCode;
}
