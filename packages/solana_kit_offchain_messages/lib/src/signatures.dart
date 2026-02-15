import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_offchain_messages/src/codecs/preamble_common.dart';
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

  final requiredSignatoryAddresses = decodeRequiredSignatoryAddresses(
    offchainMessageEnvelope.content,
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

  final updatedSignatures = <Address, SignatureBytes?>{};
  for (final entry in offchainMessageEnvelope.signatures.entries) {
    final newSig = newSignatures.entries
        .where((e) => e.key.value == entry.key.value)
        .map((e) => e.value)
        .firstOrNull;
    updatedSignatures[entry.key] = newSig ?? entry.value;
  }

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

/// Returns `true` if all signatures in the envelope are non-null.
bool isFullySignedOffchainMessageEnvelope(
  OffchainMessageEnvelope offchainMessage,
) {
  return offchainMessage.signatures.values.every((sig) => sig != null);
}

/// Asserts that all signatures in the envelope are non-null.
///
/// Throws a [SolanaError] with the missing addresses if any signatures are
/// null.
void assertIsFullySignedOffchainMessageEnvelope(
  OffchainMessageEnvelope offchainMessage,
) {
  final missingSigs = <Address>[];
  for (final entry in offchainMessage.signatures.entries) {
    if (entry.value == null) {
      missingSigs.add(entry.key);
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
/// Throws a [SolanaError] if any signatures are missing or invalid.
void verifyOffchainMessageEnvelope(
  OffchainMessageEnvelope offchainMessageEnvelope,
) {
  final signatoriesWithMissingSignatures = <Address>[];
  final signatoriesWithInvalidSignatures = <Address>[];

  final requiredSignatories = decodeRequiredSignatoryAddresses(
    offchainMessageEnvelope.content,
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
