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
  final signers = getSignersFromTransactionMessage(transactionMessage);
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
