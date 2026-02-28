import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
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
///
/// Throws a [SolanaError]:
/// - [SolanaErrorCode.transactionExpectedBlockhashLifetime] when the message
///   has no valid blockhash lifetime.
/// - [SolanaErrorCode.transactionExpectedNonceLifetime] when the message has
///   an invalid durable nonce lifetime setup.
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

  final lifetimeConstraint = _compileTransactionLifetimeConstraint(
    transactionMessage,
  );
  return TransactionWithLifetime(
    messageBytes: messageBytes,
    signatures: signatures,
    lifetimeConstraint: lifetimeConstraint,
  );
}

TransactionLifetimeConstraint _compileTransactionLifetimeConstraint(
  TransactionMessage transactionMessage,
) {
  final messageLifetimeConstraint = transactionMessage.lifetimeConstraint;
  if (messageLifetimeConstraint == null) {
    throw SolanaError(SolanaErrorCode.transactionExpectedBlockhashLifetime);
  }

  switch (messageLifetimeConstraint) {
    case BlockhashLifetimeConstraint(
      :final blockhash,
      :final lastValidBlockHeight,
    ):
      if (!isTransactionMessageWithBlockhashLifetime(transactionMessage)) {
        throw SolanaError(SolanaErrorCode.transactionExpectedBlockhashLifetime);
      }
      return TransactionBlockhashLifetime(
        blockhash: blockhash,
        lastValidBlockHeight: lastValidBlockHeight,
      );
    case DurableNonceLifetimeConstraint(:final nonce):
      if (!isTransactionMessageWithDurableNonceLifetime(transactionMessage)) {
        throw SolanaError(SolanaErrorCode.transactionExpectedNonceLifetime);
      }

      final nonceAccountAddress =
          transactionMessage.instructions.first.accounts!.first.address;
      return TransactionDurableNonceLifetime(
        nonce: nonce,
        nonceAccountAddress: nonceAccountAddress,
      );
  }
}
