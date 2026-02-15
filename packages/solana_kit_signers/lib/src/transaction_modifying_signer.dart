import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_signers/src/types.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// A signer interface that potentially modifies the provided
/// [Transaction]s before signing them.
///
/// For instance, this enables wallets to inject additional instructions
/// into the transaction before signing them. For each transaction, instead
/// of returning a signature dictionary, the [modifyAndSignTransactions]
/// function returns an updated [Transaction] with a potentially modified
/// set of instructions and signature dictionary.
///
/// Characteristics:
/// - **Sequential**. Contrary to partial signers, these cannot be executed
///   in parallel as each call can modify the provided transactions.
/// - **First signers**. For a given transaction, a modifying signer must
///   always be used before a partial signer.
/// - **Potential conflicts**. If more than one modifying signer is
///   provided, the second signer may invalidate the signature of the
///   first one.
// ignore: one_member_abstracts
abstract class TransactionModifyingSigner {
  /// The base58-encoded address of this signer.
  Address get address;

  /// Potentially modifies the provided [transactions] before signing
  /// them and returns the updated [Transaction]s.
  Future<List<Transaction>> modifyAndSignTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]);
}

/// Checks whether the provided value implements the
/// [TransactionModifyingSigner] interface.
bool isTransactionModifyingSigner(Object? value) {
  return value is TransactionModifyingSigner;
}

/// Asserts that the provided value implements the
/// [TransactionModifyingSigner] interface.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedTransactionModifyingSigner] if the check
/// fails.
void assertIsTransactionModifyingSigner(Object? value) {
  if (!isTransactionModifyingSigner(value)) {
    final addr = value is TransactionModifyingSigner ? value.address.value : '';
    throw SolanaError(
      SolanaErrorCode.signerExpectedTransactionModifyingSigner,
      {'address': addr},
    );
  }
}
