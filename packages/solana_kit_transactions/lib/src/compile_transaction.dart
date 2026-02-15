import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

import 'package:solana_kit_transactions/src/lifetime.dart';

/// Compiles a [TransactionMessage] into a [TransactionWithLifetime].
///
/// This includes the compiled bytes of the transaction message, and a map of
/// signatures. This map will have a key for each address that is required to
/// sign the transaction. The transaction will not yet have signatures for any
/// of these addresses.
///
/// The transaction message must have a fee payer set and a lifetime constraint.
TransactionWithLifetime compileTransaction(
  TransactionMessage transactionMessage,
) {
  final compiledMessage = compileTransactionMessage(transactionMessage);
  final messageBytes = getCompiledTransactionMessageEncoder().encode(
    compiledMessage,
  );

  // Extract signer addresses from the compiled message.
  final transactionSigners = compiledMessage.staticAccounts.sublist(
    0,
    compiledMessage.header.numSignerAccounts,
  );

  // Create signature map with null for all signers (preserving order).
  final signatures = <Address, SignatureBytes?>{};
  for (final signerAddress in transactionSigners) {
    signatures[signerAddress] = null;
  }

  // Extract lifetime constraint from the transaction message.
  Object? lifetimeConstraint;
  if (isTransactionMessageWithBlockhashLifetime(transactionMessage)) {
    final constraint =
        transactionMessage.lifetimeConstraint! as BlockhashLifetimeConstraint;
    lifetimeConstraint = TransactionBlockhashLifetime(
      blockhash: constraint.blockhash,
      lastValidBlockHeight: constraint.lastValidBlockHeight,
    );
  } else if (isTransactionMessageWithDurableNonceLifetime(transactionMessage)) {
    final constraint =
        transactionMessage.lifetimeConstraint!
            as DurableNonceLifetimeConstraint;
    final nonceAccountAddress =
        transactionMessage.instructions[0].accounts![0].address;
    lifetimeConstraint = TransactionDurableNonceLifetime(
      nonce: constraint.nonce,
      nonceAccountAddress: nonceAccountAddress,
    );
  }

  if (lifetimeConstraint != null) {
    return TransactionWithLifetime(
      messageBytes: messageBytes,
      signatures: signatures,
      lifetimeConstraint: lifetimeConstraint,
    );
  }

  // Even without a lifetime constraint, return a TransactionWithLifetime
  // with a placeholder. In practice, the TS code always requires one.
  return TransactionWithLifetime(
    messageBytes: messageBytes,
    signatures: signatures,
    lifetimeConstraint: const _NoLifetime(),
  );
}

/// Placeholder used when no lifetime constraint is detected.
class _NoLifetime {
  const _NoLifetime();
}
