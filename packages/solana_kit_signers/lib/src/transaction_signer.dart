import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/src/deduplicate_signers.dart';
import 'package:solana_kit_signers/src/transaction_modifying_signer.dart';
import 'package:solana_kit_signers/src/transaction_partial_signer.dart';
import 'package:solana_kit_signers/src/transaction_sending_signer.dart';

/// Checks whether the provided value implements any of the transaction
/// signer interfaces: [TransactionPartialSigner],
/// [TransactionModifyingSigner], or [TransactionSendingSigner].
bool isTransactionSigner(Object? value) {
  return isTransactionPartialSigner(value) ||
      isTransactionModifyingSigner(value) ||
      isTransactionSendingSigner(value);
}

/// Asserts that the provided value implements any of the transaction
/// signer interfaces.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedTransactionSigner] if the check fails.
void assertIsTransactionSigner(Object? value) {
  if (!isTransactionSigner(value)) {
    throw SolanaError(SolanaErrorCode.signerExpectedTransactionSigner);
  }
}

/// Gets the address from a transaction signer.
///
/// This helper function returns the address from whichever transaction
/// signer interface the value implements. Uses the shared
/// [getSignerAddress] function.
Address getTransactionSignerAddress(Object value) {
  return getSignerAddress(value);
}
