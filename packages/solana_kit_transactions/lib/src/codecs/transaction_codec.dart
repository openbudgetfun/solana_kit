import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transaction_messages/solana_kit_transaction_messages.dart';

import 'package:solana_kit_transactions/src/codecs/signatures_encoder.dart';
import 'package:solana_kit_transactions/src/transaction.dart';

/// Returns an encoder that you can use to encode a [Transaction] to a byte
/// array in a wire format appropriate for sending to the Solana network for
/// execution.
VariableSizeEncoder<Transaction> getTransactionEncoder() {
  final signaturesEncoder = getSignaturesEncoderWithSizePrefix();
  final bytesEncoder = getBytesEncoder();

  return VariableSizeEncoder<Transaction>(
    getSizeFromValue: (transaction) {
      return getEncodedSize(transaction.signatures, signaturesEncoder) +
          getEncodedSize(transaction.messageBytes, bytesEncoder);
    },
    write: (transaction, bytes, offset) => bytesEncoder.write(
      transaction.messageBytes,
      bytes,
      signaturesEncoder.write(transaction.signatures, bytes, offset),
    ),
  );
}

/// Returns a decoder that you can use to convert a byte array in the Solana
/// transaction wire format to a [Transaction] object.
VariableSizeDecoder<Transaction> getTransactionDecoder() {
  final shortU16Dec = getShortU16Decoder();
  final sigBytesDecoder = fixDecoderSize(getBytesDecoder(), 64);

  return VariableSizeDecoder<Transaction>(
    read: (bytes, offset) {
      // Decode signatures array.
      final (sigCount, sigCountEnd) = shortU16Dec.read(bytes, offset);
      var pos = sigCountEnd;
      final signatures = <Uint8List>[];
      for (var i = 0; i < sigCount; i++) {
        final (sigBytes, newPos) = sigBytesDecoder.read(bytes, pos);
        signatures.add(sigBytes);
        pos = newPos;
      }

      // Remaining bytes are the message.
      final messageBytes = Uint8List.sublistView(bytes, pos);

      // Decode signer addresses from message bytes.
      final decoded = _decodeSignerAddresses(messageBytes);
      final numRequiredSignatures = decoded.numRequiredSignatures;
      final signerAddresses = decoded.signerAddresses;

      // Signer addresses and signatures must be the same length.
      if (signerAddresses.length != signatures.length) {
        throw SolanaError(
          SolanaErrorCode.transactionMessageSignaturesMismatch,
          {
            'numRequiredSignatures': numRequiredSignatures,
            'signaturesLength': signatures.length,
            'signerAddresses': signerAddresses.map((a) => a.value).toList(),
          },
        );
      }

      // Combine signer addresses + signatures into the signatures map.
      final signaturesMap = <Address, SignatureBytes?>{};
      for (var i = 0; i < signerAddresses.length; i++) {
        final sigForAddress = signatures[i];
        if (sigForAddress.every((b) => b == 0)) {
          signaturesMap[signerAddresses[i]] = null;
        } else {
          signaturesMap[signerAddresses[i]] = SignatureBytes(sigForAddress);
        }
      }

      return (
        Transaction(
          messageBytes: Uint8List.fromList(messageBytes),
          signatures: signaturesMap,
        ),
        bytes.length,
      );
    },
  );
}

/// Returns a codec that you can use to encode from or decode to a
/// [Transaction].
VariableSizeCodec<Transaction, Transaction> getTransactionCodec() {
  final encoder = getTransactionEncoder();
  final decoder = getTransactionDecoder();
  return VariableSizeCodec<Transaction, Transaction>(
    getSizeFromValue: encoder.getSizeFromValue,
    write: encoder.write,
    read: decoder.read,
  );
}

/// Helper record for decoded signer data.
class _SignerData {
  const _SignerData({
    required this.numRequiredSignatures,
    required this.signerAddresses,
  });
  final int numRequiredSignatures;
  final List<Address> signerAddresses;
}

/// Decodes signer addresses from compiled transaction message bytes.
_SignerData _decodeSignerAddresses(Uint8List messageBytes) {
  final versionDec = getTransactionVersionDecoder();
  final u8Dec = getU8Decoder();
  final shortU16Dec = getShortU16Decoder();
  final addrDec = getAddressDecoder();

  var pos = 0;

  // Read transaction version.
  final (_, versionEnd) = versionDec.read(messageBytes, pos);
  pos = versionEnd;

  // Read first byte of header: numSignerAccounts.
  final (numRequiredSignatures, numSigEnd) = u8Dec.read(messageBytes, pos);
  pos = numSigEnd;

  // Skip next 2 bytes (numReadOnlySignedAccounts, numReadOnlyUnsignedAccounts).
  pos += 2;

  // Read static addresses array.
  final (accountCount, countEnd) = shortU16Dec.read(messageBytes, pos);
  pos = countEnd;

  final staticAddresses = <Address>[];
  for (var i = 0; i < accountCount; i++) {
    final (addr, addrEnd) = addrDec.read(messageBytes, pos);
    staticAddresses.add(addr);
    pos = addrEnd;
  }

  final signerAddresses = staticAddresses.sublist(0, numRequiredSignatures);

  return _SignerData(
    numRequiredSignatures: numRequiredSignatures,
    signerAddresses: signerAddresses,
  );
}
