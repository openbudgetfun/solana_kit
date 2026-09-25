import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';

import 'package:solana_kit_transactions/src/lifetime.dart';
import 'package:solana_kit_transactions/src/transaction.dart';

/// Cached base58 decoder instance.
Decoder<String>? _base58Decoder;

/// Given a transaction signed by its fee payer, this method will return the
/// [Signature] that uniquely identifies it.
///
/// The fee payer is the first entry in the signatures map.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionFeePayerSignatureMissing] if the fee payer
/// has not signed.
Signature getSignatureFromTransaction(Transaction transaction) {
  _base58Decoder ??= getBase58Decoder();

  // First signature is the fee payer's.
  final signatureEntries = transaction.signatures.values;
  if (signatureEntries.isEmpty) {
    throw SolanaError(SolanaErrorCode.transactionFeePayerSignatureMissing);
  }

  final signatureBytes = signatureEntries.first;
  if (signatureBytes == null) {
    throw SolanaError(SolanaErrorCode.transactionFeePayerSignatureMissing);
  }

  final transactionSignature = _base58Decoder!.decode(signatureBytes.value);
  return Signature(transactionSignature);
}

/// Given a list of [KeyPair] objects which are key pairs pertaining to
/// addresses that are required to sign a transaction, this method will
/// return a new signed transaction.
///
/// Though the resulting transaction might have every signature it needs to
/// land on the network, this function will not assert that it does.
Future<Transaction> partiallySignTransaction(
  List<KeyPair> keyPairs,
  Transaction transaction,
) async {
  Map<Address, SignatureBytes>? newSignatures;
  Set<Address>? unexpectedSigners;

  for (final keyPair in keyPairs) {
    final addr = getAddressFromPublicKey(keyPair.publicKey);
    final existingSignature = transaction.signatures[addr];

    // Check if the address is expected to sign the transaction.
    if (!transaction.signatures.containsKey(addr)) {
      unexpectedSigners ??= <Address>{};
      unexpectedSigners.add(addr);
      continue;
    }

    // Skip if there are already unexpected signers since we won't be using
    // the signatures.
    if (unexpectedSigners != null) {
      continue;
    }

    final newSignature = signBytes(
      keyPair.privateKey,
      transaction.messageBytes,
    );

    if (existingSignature != null &&
        _bytesEqual(newSignature.value, existingSignature.value)) {
      // Already have the same signature.
      continue;
    }

    newSignatures ??= <Address, SignatureBytes>{};
    newSignatures[addr] = newSignature;
  }

  if (unexpectedSigners != null && unexpectedSigners.isNotEmpty) {
    final expectedSigners = transaction.signatures.keys.toList();
    throw SolanaError(
      SolanaErrorCode.transactionAddressesCannotSignTransaction,
      {
        'expectedAddresses': expectedSigners.map((a) => a.value).toList(),
        'unexpectedAddresses': unexpectedSigners.map((a) => a.value).toList(),
      },
    );
  }

  if (newSignatures == null) {
    return transaction;
  }

  final mergedSignatures = <Address, SignatureBytes?>{
    ...transaction.signatures,
    ...newSignatures,
  };

  if (transaction is TransactionWithLifetime) {
    return TransactionWithLifetime(
      messageBytes: transaction.messageBytes,
      signatures: mergedSignatures,
      lifetimeConstraint: transaction.lifetimeConstraint,
    );
  }

  return Transaction(
    messageBytes: transaction.messageBytes,
    signatures: mergedSignatures,
  );
}

/// Given a list of [KeyPair] objects, signs the transaction and asserts that
/// it is fully signed.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionSignaturesMissing] if the resulting
/// transaction is not fully signed.
Future<Transaction> signTransaction(
  List<KeyPair> keyPairs,
  Transaction transaction,
) async {
  final out = await partiallySignTransaction(keyPairs, transaction);
  assertIsFullySignedTransaction(out);
  return out;
}

/// Returns `true` if all entries in the transaction's signatures map have
/// non-null signatures.
bool isFullySignedTransaction(Transaction transaction) {
  return transaction.signatures.values.every((sig) => sig != null);
}

/// Asserts that the transaction is fully signed.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.transactionSignaturesMissing] if any signer has a null
/// signature, providing the list of missing signer addresses.
void assertIsFullySignedTransaction(Transaction transaction) {
  final missingSigs = <Address>[];
  for (final entry in transaction.signatures.entries) {
    if (entry.value == null) {
      missingSigs.add(entry.key);
    }
  }

  if (missingSigs.isNotEmpty) {
    throw SolanaError(SolanaErrorCode.transactionSignaturesMissing, {
      'addresses': missingSigs.map((a) => a.value).toList(),
    });
  }
}

/// Compares two byte arrays for equality.
bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
