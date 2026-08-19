import 'package:solana_kit_helius/src/transactions/validate_tx_message.dart';

/// Blockhash lifetime metadata for a transaction message.
class TxMessageLifetime {
  /// Creates blockhash lifetime metadata.
  const TxMessageLifetime({
    required this.blockhash,
    required this.lastValidBlockHeight,
  });

  /// Recent blockhash.
  final String blockhash;

  /// Last block height for which the blockhash is valid.
  final int lastValidBlockHeight;
}

/// Minimal transaction signer shape used by [createTxMessage].
class TxMessageSigner {
  /// Creates a signer reference.
  const TxMessageSigner({required this.address});

  /// Signer address.
  final String address;
}

/// Minimal immutable transaction message assembled by [createTxMessage].
class TxMessage {
  /// Creates a transaction message.
  const TxMessage({
    required this.version,
    required this.feePayer,
    required this.instructions,
    this.lifetime,
  });

  /// Transaction version.
  final int version;

  /// Fee payer address.
  final String feePayer;

  /// Optional transaction lifetime.
  final TxMessageLifetime? lifetime;

  /// Instructions appended to the message in order.
  final List<Object?> instructions;
}

/// Input for [createTxMessage].
class CreateTxMessageInput {
  /// Creates transaction message input.
  const CreateTxMessageInput({
    required this.version,
    required this.feePayer,
    required this.instructions,
    this.lifetime,
  });

  /// Transaction version.
  final int version;

  /// Fee payer as an address [String] or [TxMessageSigner].
  final Object feePayer;

  /// Optional transaction lifetime.
  final TxMessageLifetime? lifetime;

  /// Instructions to append in order.
  final List<Object?> instructions;
}

/// Creates a minimal transaction message, normalizing signer fee payers to their
/// address and preserving instruction order.
///
/// Same guard `createSmartTransaction` applies: without it, `@solana/kit`
/// would silently compile a lookup account into a static address on version 1
/// transactions.
TxMessage createTxMessage(CreateTxMessageInput input) {
  // Same guard createSmartTransaction applies. Without it kit would silently
  // compile a lookup account into a static address on v1.
  assertNoAddressLookupsOnV1(input.version, input.instructions);

  final feePayer = switch (input.feePayer) {
    final String address => address,
    final TxMessageSigner signer => signer.address,
    _ => throw ArgumentError.value(input.feePayer, 'feePayer'),
  };

  return TxMessage(
    version: input.version,
    feePayer: feePayer,
    lifetime: input.lifetime,
    instructions: List<Object?>.unmodifiable(input.instructions),
  );
}
