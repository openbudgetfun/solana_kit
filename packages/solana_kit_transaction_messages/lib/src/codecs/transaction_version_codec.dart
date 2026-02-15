import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_transaction_messages/src/transaction_message.dart';

const _versionFlagMask = 0x80;

/// Returns an encoder that you can use to encode a [TransactionVersion] to a
/// byte array.
///
/// Legacy messages will produce an empty array and will not advance the offset.
/// Versioned messages will produce an array with a single byte.
VariableSizeEncoder<TransactionVersion> getTransactionVersionEncoder() {
  return VariableSizeEncoder<TransactionVersion>(
    maxSize: 1,
    getSizeFromValue: (value) => value == TransactionVersion.legacy ? 0 : 1,
    write: (value, bytes, offset) {
      if (value == TransactionVersion.legacy) {
        return offset;
      }
      final version = value.versionNumber!;
      if (version < 0 || version > 127) {
        throw SolanaError(
          SolanaErrorCode.transactionVersionNumberOutOfRange,
          {'actualVersion': version},
        );
      }
      if (version > maxSupportedTransactionVersion) {
        throw SolanaError(
          SolanaErrorCode.transactionVersionNumberNotSupported,
          {'unsupportedVersion': version},
        );
      }
      bytes[offset] = version | _versionFlagMask;
      return offset + 1;
    },
  );
}

/// Returns a decoder that you can use to decode a byte array representing a
/// [TransactionVersion].
///
/// When the byte at the current offset is determined to represent a legacy
/// transaction, this decoder will return [TransactionVersion.legacy] and will
/// not advance the offset.
VariableSizeDecoder<TransactionVersion> getTransactionVersionDecoder() {
  return VariableSizeDecoder<TransactionVersion>(
    maxSize: 1,
    read: (bytes, offset) {
      final firstByte = bytes[offset];
      if ((firstByte & _versionFlagMask) == 0) {
        // No version flag set; it's a legacy (unversioned) transaction.
        return (TransactionVersion.legacy, offset);
      } else {
        final version = firstByte ^ _versionFlagMask;
        if (version > maxSupportedTransactionVersion) {
          throw SolanaError(
            SolanaErrorCode.transactionVersionNumberNotSupported,
            {'unsupportedVersion': version},
          );
        }
        return (TransactionVersion.v0, offset + 1);
      }
    },
  );
}

/// Returns a codec that you can use to encode from or decode to
/// [TransactionVersion].
///
/// See [getTransactionVersionDecoder] and [getTransactionVersionEncoder].
Codec<TransactionVersion, TransactionVersion> getTransactionVersionCodec() {
  return combineCodec(
    getTransactionVersionEncoder(),
    getTransactionVersionDecoder(),
  );
}
