import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/constants.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/crypto.dart';
import 'package:solana_kit_mobile_wallet_adapter_protocol/src/sequence_number.dart';

/// Result of decrypting an MWA encrypted message.
class DecryptedMessage {
  const DecryptedMessage({
    required this.plaintext,
    required this.sequenceNumber,
  });

  /// The decrypted UTF-8 plaintext.
  final String plaintext;

  /// The sequence number extracted from the message.
  final int sequenceNumber;
}

/// Encrypts a plaintext string for transmission over an MWA session.
///
/// Wire format: `[4B seq big-endian][12B random IV][ciphertext + 16B GCM tag]`
///
/// The sequence number is used as Additional Authenticated Data (AAD) to
/// prevent replay attacks.
Uint8List encryptMessage(
  String plaintext,
  int sequenceNumber,
  Uint8List sharedSecret,
) {
  final sequenceNumberVector = createSequenceNumberVector(sequenceNumber);
  final iv = randomBytes(mwaIvBytes);

  Uint8List ciphertextWithTag;
  try {
    ciphertextWithTag = aesGcmEncrypt(
      plaintext: Uint8List.fromList(utf8.encode(plaintext)),
      key: sharedSecret,
      nonce: iv,
      aad: sequenceNumberVector,
    );
  } on Object {
    throw SolanaError(SolanaErrorCode.mwaEncryptionFailed);
  }

  // Build wire format: [seq (4)] [IV (12)] [ciphertext + tag]
  final response = Uint8List(
    mwaSequenceNumberBytes + mwaIvBytes + ciphertextWithTag.length,
  )
    ..setAll(0, sequenceNumberVector)
    ..setAll(mwaSequenceNumberBytes, iv)
    ..setAll(mwaSequenceNumberBytes + mwaIvBytes, ciphertextWithTag);

  return response;
}

/// Decrypts an MWA encrypted message.
///
/// Wire format: `[4B seq big-endian][12B random IV][ciphertext + 16B GCM tag]`
///
/// Returns the decrypted plaintext and the extracted sequence number.
DecryptedMessage decryptMessage(
  Uint8List message,
  Uint8List sharedSecret,
) {
  // Extract components from wire format.
  final sequenceNumberVector = message.sublist(0, mwaSequenceNumberBytes);
  final iv = message.sublist(
    mwaSequenceNumberBytes,
    mwaSequenceNumberBytes + mwaIvBytes,
  );
  final ciphertextWithTag = message.sublist(
    mwaSequenceNumberBytes + mwaIvBytes,
  );

  // Parse sequence number (big-endian uint32).
  final sequenceNumber = ByteData.sublistView(sequenceNumberVector)
      .getUint32(0);

  List<int> plaintextBytes;
  try {
    plaintextBytes = aesGcmDecrypt(
      ciphertextWithTag: ciphertextWithTag,
      key: sharedSecret,
      nonce: iv,
      aad: sequenceNumberVector,
    );
  } on Object {
    throw SolanaError(SolanaErrorCode.mwaDecryptionFailed);
  }

  return DecryptedMessage(
    plaintext: utf8.decode(plaintextBytes),
    sequenceNumber: sequenceNumber,
  );
}
