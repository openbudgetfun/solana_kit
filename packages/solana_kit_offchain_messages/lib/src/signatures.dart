import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/src/codecs/message.dart';
import 'package:solana_kit_offchain_messages/src/envelope.dart';

/// Partially signs an [OffchainMessageEnvelope] with the given [keyPairs].
///
/// Signs the envelope content with any key pairs whose public key addresses
/// appear in the required signatories. Returns a new envelope with the
/// signatures updated.
///
/// Throws a [SolanaError] if any key pair does not correspond to a required
/// signatory address.
OffchainMessageEnvelope partiallySignOffchainMessageEnvelope(
  List<KeyPair> keyPairs,
  OffchainMessageEnvelope offchainMessageEnvelope,
) {
  final newSignatures = <Address, SignatureBytes>{};
  final unexpectedSigners = <Address>{};

  final requiredSignatoryAddresses = _getRequiredSignatoryAddresses(
    offchainMessageEnvelope,
  );

  for (final keyPair in keyPairs) {
    final addr = getAddressFromPublicKey(keyPair.publicKey);

    // Check if the address is an expected signer.
    if (!requiredSignatoryAddresses.any((a) => a.value == addr.value)) {
      unexpectedSigners.add(addr);
      continue;
    }

    // Skip if there are unexpected signers already.
    if (unexpectedSigners.isNotEmpty) continue;

    final existingSignature = offchainMessageEnvelope.signatures.entries
        .where((e) => e.key.value == addr.value)
        .map((e) => e.value)
        .firstOrNull;

    final newSignature = signBytes(
      keyPair.privateKey,
      offchainMessageEnvelope.content,
    );

    if (existingSignature != null &&
        bytesEqual(newSignature.value, existingSignature.value)) {
      // Already have the same signature.
      continue;
    }

    newSignatures[addr] = newSignature;
  }

  if (unexpectedSigners.isNotEmpty) {
    throw SolanaError(
      SolanaErrorCode.offchainMessageAddressesCannotSignOffchainMessage,
      {
        'expectedAddresses': requiredSignatoryAddresses
            .map((a) => a.value)
            .toList(),
        'unexpectedAddresses': unexpectedSigners.map((a) => a.value).toList(),
      },
    );
  }

  if (newSignatures.isEmpty) {
    return offchainMessageEnvelope;
  }

  final updatedSignatures = <Address, SignatureBytes?>{
    ...offchainMessageEnvelope.signatures,
    ...newSignatures,
  };

  return OffchainMessageEnvelope(
    content: offchainMessageEnvelope.content,
    signatures: Map<Address, SignatureBytes?>.unmodifiable(updatedSignatures),
  );
}

/// Signs an [OffchainMessageEnvelope] with the given [keyPairs].
///
/// Like [partiallySignOffchainMessageEnvelope], but asserts that all required
/// signatories have provided signatures after signing.
///
/// Throws a [SolanaError] if the resulting envelope is not fully signed.
OffchainMessageEnvelope signOffchainMessageEnvelope(
  List<KeyPair> keyPairs,
  OffchainMessageEnvelope offchainMessageEnvelope,
) {
  final result = partiallySignOffchainMessageEnvelope(
    keyPairs,
    offchainMessageEnvelope,
  );
  assertIsFullySignedOffchainMessageEnvelope(result);
  return result;
}

/// Returns `true` if the message is valid and every required signer has a
/// non-null signature.
///
/// This checks signature presence. Use [verifyOffchainMessageEnvelope] to
/// verify signatures cryptographically.
bool isFullySignedOffchainMessageEnvelope(
  OffchainMessageEnvelope offchainMessage,
) {
  try {
    assertIsFullySignedOffchainMessageEnvelope(offchainMessage);
    return true;
  } on SolanaError {
    return false;
  } on FormatException {
    return false;
  }
}

/// Asserts that the message is valid and every required signer has a non-null
/// signature, including addresses omitted from the signature map.
///
/// Throws a [SolanaError] with the missing addresses if signatures are absent.
/// This does not verify signatures cryptographically.
void assertIsFullySignedOffchainMessageEnvelope(
  OffchainMessageEnvelope offchainMessage,
) {
  final missingSigs = <Address>[];
  for (final address in _getRequiredSignatoryAddresses(offchainMessage)) {
    if (offchainMessage.signatures[address] == null) {
      missingSigs.add(address);
    }
  }

  if (missingSigs.isNotEmpty) {
    throw SolanaError(SolanaErrorCode.offchainMessageSignaturesMissing, {
      'addresses': missingSigs.map((a) => a.value).toList(),
    });
  }
}

/// Verifies that all required signatories have valid signatures.
///
/// Rejects malformed messages, then throws a [SolanaError] if any required
/// signatures are missing or invalid.
void verifyOffchainMessageEnvelope(
  OffchainMessageEnvelope offchainMessageEnvelope,
) {
  final signatoriesWithMissingSignatures = <Address>[];
  final signatoriesWithInvalidSignatures = <Address>[];

  final requiredSignatories = _getRequiredSignatoryAddresses(
    offchainMessageEnvelope,
  );

  for (final addr in requiredSignatories) {
    final signature = offchainMessageEnvelope.signatures.entries
        .where((e) => e.key.value == addr.value)
        .map((e) => e.value)
        .firstOrNull;

    if (signature == null) {
      signatoriesWithMissingSignatures.add(addr);
    } else {
      final publicKeyBytes = getPublicKeyFromAddress(addr);
      final isValid = verifySignature(
        publicKeyBytes,
        signature,
        offchainMessageEnvelope.content,
      );
      if (!isValid) {
        signatoriesWithInvalidSignatures.add(addr);
      }
    }
  }

  if (signatoriesWithMissingSignatures.isNotEmpty ||
      signatoriesWithInvalidSignatures.isNotEmpty) {
    throw SolanaError(
      SolanaErrorCode.offchainMessageSignatureVerificationFailure,
      {
        'signatoriesWithMissingSignatures': signatoriesWithMissingSignatures
            .map((a) => a.value)
            .toList(),
        'signatoriesWithInvalidSignatures': signatoriesWithInvalidSignatures
            .map((a) => a.value)
            .toList(),
      },
    );
  }
}

List<Address> _getRequiredSignatoryAddresses(OffchainMessageEnvelope envelope) {
  // Validate the body and version-specific signer rules before trusting the
  // preamble for signing or authorization checks.
  return getOffchainMessageDecoder()
      .decode(envelope.content)
      .requiredSignatories
      .map((signatory) => signatory.address)
      .toList();
}
