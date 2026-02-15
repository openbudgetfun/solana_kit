import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/src/message_partial_signer.dart';
import 'package:solana_kit_signers/src/signable_message.dart';
import 'package:solana_kit_signers/src/transaction_partial_signer.dart';
import 'package:solana_kit_signers/src/types.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';

/// Defines a signer that uses a [KeyPair] to sign messages and
/// transactions.
///
/// It implements both the [MessagePartialSigner] and
/// [TransactionPartialSigner] interfaces and keeps track of the [KeyPair]
/// instance used to sign messages and transactions.
class KeyPairSigner implements MessagePartialSigner, TransactionPartialSigner {
  /// Creates a [KeyPairSigner] with the given [address] and [keyPair].
  const KeyPairSigner({required this.address, required this.keyPair});

  @override
  final Address address;

  /// The key pair used for signing.
  final KeyPair keyPair;

  @override
  Future<List<Map<Address, SignatureBytes>>> signMessages(
    List<SignableMessage> messages, [
    SignerConfig? config,
  ]) async {
    return messages.map((message) {
      final sig = signBytes(keyPair.privateKey, message.content);
      return Map<Address, SignatureBytes>.unmodifiable({address: sig});
    }).toList();
  }

  @override
  Future<List<Map<Address, SignatureBytes>>> signTransactions(
    List<Transaction> transactions, [
    TransactionSignerConfig? config,
  ]) async {
    final results = <Map<Address, SignatureBytes>>[];
    for (final transaction in transactions) {
      final signedTransaction = await partiallySignTransaction([
        keyPair,
      ], transaction);
      final sig = signedTransaction.signatures[address];
      results.add(
        Map<Address, SignatureBytes>.unmodifiable(
          sig != null ? {address: sig} : <Address, SignatureBytes>{},
        ),
      );
    }
    return results;
  }
}

/// Creates a [KeyPairSigner] from a provided [KeyPair].
///
/// ```dart
/// final keyPair = generateKeyPair();
/// final signer = createSignerFromKeyPair(keyPair);
/// ```
KeyPairSigner createSignerFromKeyPair(KeyPair keyPair) {
  final addr = getAddressFromPublicKey(keyPair.publicKey);
  return KeyPairSigner(address: addr, keyPair: keyPair);
}

/// Generates a signer capable of signing messages and transactions by
/// generating a [KeyPair] and creating a [KeyPairSigner] from it.
///
/// ```dart
/// final signer = generateKeyPairSigner();
/// ```
KeyPairSigner generateKeyPairSigner() {
  return createSignerFromKeyPair(generateKeyPair());
}

/// Creates a new [KeyPairSigner] from a 64-bytes [Uint8List] secret key
/// (private key and public key).
///
/// ```dart
/// final signer = createKeyPairSignerFromBytes(keypairBytes);
/// ```
KeyPairSigner createKeyPairSignerFromBytes(Uint8List bytes) {
  return createSignerFromKeyPair(createKeyPairFromBytes(bytes));
}

/// Creates a new [KeyPairSigner] from a 32-bytes [Uint8List] private key.
///
/// ```dart
/// final signer = createKeyPairSignerFromPrivateKeyBytes(privateKeyBytes);
/// ```
KeyPairSigner createKeyPairSignerFromPrivateKeyBytes(Uint8List bytes) {
  return createSignerFromKeyPair(createKeyPairFromPrivateKeyBytes(bytes));
}

/// Checks whether the provided value implements the [KeyPairSigner]
/// interface.
bool isKeyPairSigner(Object? value) {
  return value is KeyPairSigner;
}

/// Asserts that the provided value implements the [KeyPairSigner]
/// interface.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.signerExpectedKeyPairSigner] if the check fails.
void assertIsKeyPairSigner(Object? value) {
  if (!isKeyPairSigner(value)) {
    throw SolanaError(SolanaErrorCode.signerExpectedKeyPairSigner);
  }
}
