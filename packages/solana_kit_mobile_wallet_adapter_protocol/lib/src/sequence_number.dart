import 'dart:typed_data';

import 'package:solana_kit_errors/solana_kit_errors.dart';

import 'package:solana_kit_mobile_wallet_adapter_protocol/src/constants.dart';

/// Creates a 4-byte big-endian representation of [sequenceNumber] for use
/// as additional authenticated data (AAD) in AES-GCM encryption.
///
/// Throws a [SolanaError] with code
/// [SolanaErrorCode.mwaSequenceNumberOverflow] if [sequenceNumber] is >= 2^32.
Uint8List createSequenceNumberVector(int sequenceNumber) {
  if (sequenceNumber >= mwaMaxSequenceNumber) {
    throw SolanaError(SolanaErrorCode.mwaSequenceNumberOverflow, {
      'sequenceNumber': sequenceNumber,
    });
  }
  final bytes = ByteData(mwaSequenceNumberBytes)..setUint32(0, sequenceNumber);
  return bytes.buffer.asUint8List();
}
