import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Returns an encoder that always writes a predefined constant byte sequence.
///
/// This encoder ensures that encoding always produces the specified byte
/// array, ignoring any input values.
FixedSizeEncoder<void> getConstantEncoder(Uint8List constant) {
  return FixedSizeEncoder<void>(
    fixedSize: constant.length,
    write: (_, Uint8List bytes, int offset) {
      bytes.setAll(offset, constant);
      return offset + constant.length;
    },
  );
}

/// Returns a decoder that verifies a predefined constant byte sequence.
///
/// This decoder reads the next bytes and checks that they match the provided
/// [constant]. If the bytes differ, it throws an error.
FixedSizeDecoder<void> getConstantDecoder(Uint8List constant) {
  return FixedSizeDecoder<void>(
    fixedSize: constant.length,
    read: (Uint8List bytes, int offset) {
      if (!containsBytes(bytes, constant, offset)) {
        // Build hex strings inline to avoid dependency on codecs_strings.
        final hexConstant = _toHex(constant);
        final hexData = _toHex(bytes);
        throw SolanaError(SolanaErrorCode.codecsInvalidConstant, {
          'hexConstant': hexConstant,
          'hexData': hexData,
          'offset': offset,
        });
      }
      return (null, offset + constant.length);
    },
  );
}

/// Returns a codec that encodes and decodes a predefined constant byte
/// sequence.
///
/// - **Encoding:** Always writes the specified byte array.
/// - **Decoding:** Asserts that the next bytes match the constant, throwing
///   an error if they do not.
FixedSizeCodec<void, void> getConstantCodec(Uint8List constant) {
  return combineCodec(
        getConstantEncoder(constant),
        getConstantDecoder(constant),
      )
      as FixedSizeCodec<void, void>;
}

String _toHex(Uint8List bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
