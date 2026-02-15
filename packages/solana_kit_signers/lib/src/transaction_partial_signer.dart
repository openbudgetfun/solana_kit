import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/src/types.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// A signer interface that signs an array of [Transaction]s without
/// modifying their content.
///
/// It defines a [signTransactions] function that returns a signature
/// dictionary for each provided transaction. Such signature dictionaries
/// are expected to be merged with the existing ones if any.
///
/// Characteristics:
/// - **Parallel**. It returns a signature dictionary for each provided
///   transaction without modifying them, making it possible for multiple
///   partial signers to sign the same transaction in parallel.
/// - **Flexible order**. The order in which we use these signers for
///   a given transaction doesn't matter.
// ignore: one_member_abstracts
abstract class TransactionPartialSigner {
  /// The base58-encoded address of this signer.
  Address get address;

  /// Signs the provided [transactions] and returns a signature dictionary
  /// for each transaction.
  Future<List<Map<Address, SignatureBytes>>> signTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]);
}

/// Checks whether the provided value implements the
/// [TransactionPartialSigner] interface.
bool isTransactionPartialSigner(Object? value) {
  return value is TransactionPartialSigner;
}

/// Asserts that the provided value implements the
/// [TransactionPartialSigner] interface.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedTransactionPartialSigner] if the check
/// fails.
void assertIsTransactionPartialSigner(Object? value) {
  if (!isTransactionPartialSigner(value)) {
    final addr = value is TransactionPartialSigner ? value.address.value : '';
    throw SolanaError(SolanaErrorCode.signerExpectedTransactionPartialSigner, {
      'address': addr,
    });
  }
}
