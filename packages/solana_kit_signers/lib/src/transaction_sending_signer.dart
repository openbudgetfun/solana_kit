import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/src/types.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// A signer interface that signs one or multiple transactions before
/// sending them immediately to the blockchain.
///
/// It defines a [signAndSendTransactions] function that returns the
/// transaction signature (i.e. its identifier) for each provided
/// [Transaction].
///
/// This interface is required for PDA wallets and other types of wallets
/// that don't provide an interface for signing transactions without
/// sending them.
///
/// Characteristics:
/// - **Single signer**. Since this signer also sends the provided
///   transactions, we can only use a single [TransactionSendingSigner]
///   for a given set of transactions.
/// - **Last signer**. Trivially, that signer must also be the last one
///   used.
/// - **Potential conflicts**. Since signers may decide to modify the given
///   transactions before sending them, they may invalidate previous
///   signatures.
// ignore: one_member_abstracts
abstract class TransactionSendingSigner {
  /// The base58-encoded address of this signer.
  Address get address;

  /// Signs and sends the provided [transactions], returning the signature
  /// for each transaction.
  Future<List<SignatureBytes>> signAndSendTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]);
}

/// Checks whether the provided value implements the
/// [TransactionSendingSigner] interface.
bool isTransactionSendingSigner(Object? value) {
  return value is TransactionSendingSigner;
}

/// Asserts that the provided value implements the
/// [TransactionSendingSigner] interface.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedTransactionSendingSigner] if the check
/// fails.
void assertIsTransactionSendingSigner(Object? value) {
  if (!isTransactionSendingSigner(value)) {
    final addr = value is TransactionSendingSigner ? value.address.value : '';
    throw SolanaError(SolanaErrorCode.signerExpectedTransactionSendingSigner, {
      'address': addr,
    });
  }
}
