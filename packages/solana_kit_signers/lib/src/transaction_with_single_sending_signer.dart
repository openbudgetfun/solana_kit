import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/src/account_signer_meta.dart';
import 'package:solana_kit_signers/src/transaction_modifying_signer.dart';
import 'package:solana_kit_signers/src/transaction_partial_signer.dart';
import 'package:solana_kit_signers/src/transaction_sending_signer.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

/// Checks whether the provided transaction message has exactly one
/// [TransactionSendingSigner].
///
/// This can be useful when using
/// `signAndSendTransactionMessageWithSigners` to provide a fallback
/// strategy in case the transaction message cannot be sent using that
/// function.
bool isTransactionMessageWithSingleSendingSigner(
  TransactionMessage transactionMessage,
) {
  try {
    assertIsTransactionMessageWithSingleSendingSigner(transactionMessage);
    return true;
  } on Object {
    return false;
  }
}

/// Asserts that the provided transaction message has exactly one
/// [TransactionSendingSigner].
///
/// This delegates to [assertContainsResolvableTransactionSendingSigner]
/// using the signers extracted from the transaction message.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerTransactionSendingSignerMissing] if no sending
/// signer exists.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerTransactionCannotHaveMultipleSendingSigners] if
/// there are more than one sending-only signers.
void assertIsTransactionMessageWithSingleSendingSigner(
  TransactionMessage transactionMessage,
) {
  assertContainsResolvableTransactionSendingSigner(
    getSignersFromTransactionMessage(transactionMessage),
  );
}

/// Asserts that the provided signers contain at least one
/// [TransactionSendingSigner] that can be unambiguously resolved.
///
/// This means the signers must contain at least one sending signer, and at
/// most one sending-only signer (i.e. a signer that implements
/// [TransactionSendingSigner] but not [TransactionPartialSigner] or
/// [TransactionModifyingSigner]). Composite signers that also implement
/// other interfaces can be demoted to non-sending roles, so multiple
/// composite sending signers are allowed.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerTransactionSendingSignerMissing] if no sending
/// signer is found.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerTransactionCannotHaveMultipleSendingSigners] if
/// more than one sending-only signer is found.
///
/// See also: `signAndSendTransactionWithSigners`,
/// [assertIsTransactionMessageWithSingleSendingSigner].
void assertContainsResolvableTransactionSendingSigner(
  List<Object> signers,
) {
  final sendingSigners = signers.where(isTransactionSendingSigner).toList();

  if (sendingSigners.isEmpty) {
    throw SolanaError(SolanaErrorCode.signerTransactionSendingSignerMissing);
  }

  // When identifying if there are multiple sending signers, we only need
  // to check for sending signers that do not implement other transaction
  // signer interfaces as they will be used as these other signer
  // interfaces in case of a conflict.
  final sendingOnlySigners = sendingSigners
      .where(
        (signer) =>
            !isTransactionPartialSigner(signer) &&
            !isTransactionModifyingSigner(signer),
      )
      .toList();

  if (sendingOnlySigners.length > 1) {
    throw SolanaError(
      SolanaErrorCode.signerTransactionCannotHaveMultipleSendingSigners,
    );
  }
}
