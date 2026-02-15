/// The base configuration object for all signers -- including transaction
/// and message signers.
class SignerConfig {
  /// Creates a [SignerConfig] with an optional [aborted] flag.
  const SignerConfig({this.aborted = false});

  /// Whether the signing operation has been aborted.
  final bool aborted;
}

/// The base configuration object for transaction signers only.
class TransactionSignerConfig extends SignerConfig {
  /// Creates a [TransactionSignerConfig] with an optional [aborted] flag
  /// and [minContextSlot].
  const TransactionSignerConfig({super.aborted, this.minContextSlot});

  /// Signers that simulate transactions (eg. wallets) might be interested in
  /// knowing which slot was current when the transaction was prepared. They
  /// can use this information to ensure that they don't run the simulation
  /// at too early a slot.
  final BigInt? minContextSlot;
}
