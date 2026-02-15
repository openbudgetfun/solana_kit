import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/src/account_signer_meta.dart';
import 'package:solana_kit_signers/src/deduplicate_signers.dart';
import 'package:solana_kit_signers/src/transaction_modifying_signer.dart';
import 'package:solana_kit_signers/src/transaction_partial_signer.dart';
import 'package:solana_kit_signers/src/transaction_sending_signer.dart';
import 'package:solana_kit_signers/src/transaction_signer.dart';
import 'package:solana_kit_signers/src/transaction_with_single_sending_signer.dart';
import 'package:solana_kit_signers/src/types.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Extracts all transaction signers inside the provided transaction message
/// and uses them to return a signed transaction.
///
/// It first uses all [TransactionModifyingSigner]s sequentially before
/// using all [TransactionPartialSigner]s in parallel.
///
/// If a composite signer implements both interfaces, it will be used as a
/// [TransactionModifyingSigner] if no other signer implements that
/// interface. Otherwise, it will be used as a [TransactionPartialSigner].
///
/// This function ignores [TransactionSendingSigner]s as it does not send
/// the transaction.
Future<Transaction> partiallySignTransactionMessageWithSigners(
  TransactionMessage transactionMessage, [
  TransactionSignerConfig? config,
]) async {
  final allSigners = deduplicateSigners(
    getSignersFromTransactionMessage(
      transactionMessage,
    ).where(isTransactionSigner).toList(),
  );

  final categorized = _categorizeTransactionSigners(
    allSigners,
    identifySendingSigner: false,
  );

  return _signModifyingAndPartialTransactionSigners(
    transactionMessage,
    categorized.modifyingSigners,
    categorized.partialSigners,
    config,
  );
}

/// Extracts all transaction signers inside the provided transaction message
/// and uses them to return a signed transaction before asserting that all
/// signatures required by the transaction are present.
Future<Transaction> signTransactionMessageWithSigners(
  TransactionMessage transactionMessage, [
  TransactionSignerConfig? config,
]) async {
  final signedTransaction = await partiallySignTransactionMessageWithSigners(
    transactionMessage,
    config,
  );
  assertIsFullySignedTransaction(signedTransaction);
  return signedTransaction;
}

/// Extracts all transaction signers inside the provided transaction message
/// and uses them to sign it before sending it immediately to the
/// blockchain.
///
/// It returns the signature of the sent transaction (i.e. its identifier)
/// as bytes.
Future<SignatureBytes> signAndSendTransactionMessageWithSigners(
  TransactionMessage transactionMessage, [
  TransactionSignerConfig? config,
]) async {
  assertIsTransactionMessageWithSingleSendingSigner(transactionMessage);

  final allSigners = deduplicateSigners(
    getSignersFromTransactionMessage(
      transactionMessage,
    ).where(isTransactionSigner).toList(),
  );

  final categorized = _categorizeTransactionSigners(allSigners);

  if (config != null && config.aborted) {
    throw StateError('The operation was aborted');
  }

  final signedTransaction = await _signModifyingAndPartialTransactionSigners(
    transactionMessage,
    categorized.modifyingSigners,
    categorized.partialSigners,
    config,
  );

  if (categorized.sendingSigner == null) {
    throw SolanaError(SolanaErrorCode.signerTransactionSendingSignerMissing);
  }

  if (config != null && config.aborted) {
    throw StateError('The operation was aborted');
  }

  final signatures = await categorized.sendingSigner!.signAndSendTransactions([
    signedTransaction,
  ], config);

  if (config != null && config.aborted) {
    throw StateError('The operation was aborted');
  }

  return signatures[0];
}

/// Result of categorizing transaction signers.
class _CategorizedSigners {
  const _CategorizedSigners({
    required this.modifyingSigners,
    required this.partialSigners,
    this.sendingSigner,
  });

  final List<TransactionModifyingSigner> modifyingSigners;
  final List<TransactionPartialSigner> partialSigners;
  final TransactionSendingSigner? sendingSigner;
}

/// Identifies each provided TransactionSigner and categorizes them into
/// their respective types.
_CategorizedSigners _categorizeTransactionSigners(
  List<Object> signers, {
  bool identifySendingSigner = true,
}) {
  // Identify the unique sending signer that should be used.
  final sendingSigner = identifySendingSigner
      ? _identifyTransactionSendingSigner(signers)
      : null;

  // Now, focus on the other signers.
  final otherSigners = signers
      .where(
        (signer) =>
            !identical(signer, sendingSigner) &&
            (isTransactionModifyingSigner(signer) ||
                isTransactionPartialSigner(signer)),
      )
      .toList();

  // Identify the modifying signers from the other signers.
  final modifyingSigners = _identifyTransactionModifyingSigners(otherSigners);

  // Use any remaining signers as partial signers.
  final partialSigners = otherSigners
      .where(isTransactionPartialSigner)
      .where((signer) => !modifyingSigners.contains(signer))
      .cast<TransactionPartialSigner>()
      .toList();

  return _CategorizedSigners(
    modifyingSigners: modifyingSigners,
    partialSigners: partialSigners,
    sendingSigner: sendingSigner,
  );
}

/// Identifies the best signer to use as a TransactionSendingSigner.
TransactionSendingSigner? _identifyTransactionSendingSigner(
  List<Object> signers,
) {
  final sendingSigners = signers.where(isTransactionSendingSigner).toList();
  if (sendingSigners.isEmpty) return null;

  // Prefer sending signers that do not offer other interfaces.
  final sendingOnlySigners = sendingSigners
      .where(
        (signer) =>
            !isTransactionModifyingSigner(signer) &&
            !isTransactionPartialSigner(signer),
      )
      .toList();
  if (sendingOnlySigners.isNotEmpty) {
    return sendingOnlySigners[0] as TransactionSendingSigner;
  }

  // Otherwise, choose any sending signer.
  return sendingSigners[0] as TransactionSendingSigner;
}

/// Identifies the best signers to use as TransactionModifyingSigners.
List<TransactionModifyingSigner> _identifyTransactionModifyingSigners(
  List<Object> signers,
) {
  final modifyingSigners = signers.where(isTransactionModifyingSigner).toList();
  if (modifyingSigners.isEmpty) return [];

  // Prefer modifying signers that do not offer partial signing.
  final nonPartialSigners = modifyingSigners
      .where((signer) => !isTransactionPartialSigner(signer))
      .cast<TransactionModifyingSigner>()
      .toList();
  if (nonPartialSigners.isNotEmpty) return nonPartialSigners;

  // Otherwise, choose only one modifying signer (whichever).
  return [modifyingSigners[0] as TransactionModifyingSigner];
}

/// Signs a transaction using the provided TransactionModifyingSigners
/// sequentially followed by the TransactionPartialSigners in parallel.
Future<Transaction> _signModifyingAndPartialTransactionSigners(
  TransactionMessage transactionMessage,
  List<TransactionModifyingSigner> modifyingSigners,
  List<TransactionPartialSigner> partialSigners, [
  TransactionSignerConfig? config,
]) async {
  // Compile the transaction.
  var transaction = compileTransaction(transactionMessage) as Transaction;

  // Handle modifying signers sequentially.
  for (final modifyingSigner in modifyingSigners) {
    if (config != null && config.aborted) {
      throw StateError('The operation was aborted');
    }
    final results = await modifyingSigner.modifyAndSignTransactions([
      transaction,
    ], config);
    transaction = results[0];
  }

  // Handle partial signers in parallel.
  if (config != null && config.aborted) {
    throw StateError('The operation was aborted');
  }

  final signatureDictionaries = await Future.wait(
    partialSigners.map((partialSigner) async {
      final signatures = await partialSigner.signTransactions([
        transaction,
      ], config);
      return signatures[0];
    }),
  );

  // Merge all signatures.
  final mergedSignatures = <Address, SignatureBytes?>{
    ...transaction.signatures,
  };
  for (final sigDict in signatureDictionaries) {
    mergedSignatures.addAll(sigDict);
  }

  if (transaction is TransactionWithLifetime) {
    return TransactionWithLifetime(
      messageBytes: transaction.messageBytes,
      signatures: Map<Address, SignatureBytes?>.unmodifiable(mergedSignatures),
      lifetimeConstraint: transaction.lifetimeConstraint,
    );
  }

  return Transaction(
    messageBytes: transaction.messageBytes,
    signatures: Map<Address, SignatureBytes?>.unmodifiable(mergedSignatures),
  );
}
