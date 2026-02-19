import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/src/assertions.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

/// Creates a [VariableSizeEncoder] for Solana's shortU16 compact encoding.
///
/// The shortU16 encoding uses 1-3 bytes to encode values in the range
/// [0, 65535]:
/// - Values 0-127: 1 byte
/// - Values 128-16383: 2 bytes
/// - Values 16384-65535: 3 bytes
///
/// Each byte stores 7 bits of data; bit 7 is a continuation flag indicating
/// that more bytes follow.
VariableSizeEncoder<num> getShortU16Encoder() {
  return VariableSizeEncoder<num>(
    maxSize: 3,
    getSizeFromValue: (value) {
      final intValue = value.toInt();
      if (intValue <= 0x7f) return 1;
      if (intValue <= 0x3fff) return 2;
      return 3;
    },
    write: (value, bytes, offset) {
      assertNumberIsBetweenForCodec('shortU16', 0, 65535, value);
      var remaining = value.toInt();
      var currentOffset = offset;
      while (remaining > 0x7f) {
        bytes[currentOffset] = (remaining & 0x7f) | 0x80;
        remaining >>= 7;
        currentOffset++;
      }
      bytes[currentOffset] = remaining;
      return currentOffset + 1;
    },
  );
}

/// Creates a [VariableSizeDecoder] for Solana's shortU16 compact encoding.
///
/// Decodes 1-3 bytes into an [int] in the range [0, 65535].
///
/// See [getShortU16Encoder] for encoding details.
VariableSizeDecoder<int> getShortU16Decoder() {
  return VariableSizeDecoder<int>(
    maxSize: 3,
    read: (bytes, offset) {
      var result = 0;
      var currentOffset = offset;
      var shift = 0;
      while (true) {
        if (currentOffset >= bytes.length) {
          throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
            'codecDescription': 'shortU16',
            'expected': currentOffset - offset + 1,
            'bytesLength': bytes.length - offset,
          });
        }
        final byte = bytes[currentOffset];
        result |= (byte & 0x7f) << shift;
        currentOffset++;
        if ((byte & 0x80) == 0) break;
        shift += 7;
        // shortU16 uses at most 3 bytes (shifts 0, 7, 14). If shift exceeds
        // 14, the input is malformed with too many continuation bytes.
        if (shift > 14) {
          throw SolanaError(SolanaErrorCode.codecsNumberOutOfRange, {
            'codecDescription': 'shortU16',
            'min': 0,
            'max': 65535,
            'value': result,
          });
        }
      }
      return (result, currentOffset);
    },
  );
}

/// Creates a [VariableSizeCodec] for Solana's shortU16 compact encoding.
///
/// Combines [getShortU16Encoder] and [getShortU16Decoder].
///
/// See [getShortU16Encoder] for encoding details.
VariableSizeCodec<num, int> getShortU16Codec() =>
    combineCodec(getShortU16Encoder(), getShortU16Decoder())
        as VariableSizeCodec<num, int>;
