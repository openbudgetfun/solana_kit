import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_strings/src/assertions.dart';

/// Returns an encoder for base-X encoded strings using bit re-slicing.
///
/// This encoder serializes strings by dividing the input into custom-sized
/// bit chunks, mapping them to an alphabet, and encoding the result into a
/// byte array. This approach is commonly used for encoding schemes where
/// the alphabet's length is a power of 2, such as base-16 or base-64.
///
/// For more details, see [getBaseXResliceCodec].
VariableSizeEncoder<String> getBaseXResliceEncoder(String alphabet, int bits) {
  return VariableSizeEncoder<String>(
    getSizeFromValue: (value) => (value.length * bits) ~/ 8,
    write: (value, bytes, offset) {
      assertValidBaseString(alphabet, value);
      if (value.isEmpty) return offset;
      final charIndices = [
        for (var i = 0; i < value.length; i++) alphabet.indexOf(value[i]),
      ];
      final reslicedBytes = _reslice(charIndices, bits, 8, false);
      bytes.setAll(offset, reslicedBytes);
      return reslicedBytes.length + offset;
    },
  );
}

/// Returns a decoder for base-X encoded strings using bit re-slicing.
///
/// This decoder deserializes base-X encoded strings by re-slicing the bits
/// of a byte array into custom-sized chunks and mapping them to a specified
/// alphabet.
///
/// For more details, see [getBaseXResliceCodec].
VariableSizeDecoder<String> getBaseXResliceDecoder(String alphabet, int bits) {
  return VariableSizeDecoder<String>(
    read: (rawBytes, offset) {
      final bytes = offset == 0 ? rawBytes : rawBytes.sublist(offset);
      if (bytes.isEmpty) return ('', rawBytes.length);
      final charIndices = _reslice(bytes.toList(), 8, bits, true);
      return (charIndices.map((i) => alphabet[i]).join(), rawBytes.length);
    },
  );
}

/// Returns a codec for encoding and decoding base-X strings using bit
/// re-slicing.
///
/// This codec serializes strings by dividing the input into custom-sized
/// bit chunks, mapping them to a given alphabet, and encoding the result
/// into bytes. It is particularly suited for encoding schemes where the
/// alphabet's length is a power of 2, such as base-16 or base-64.
VariableSizeCodec<String, String> getBaseXResliceCodec(
  String alphabet,
  int bits,
) {
  return combineCodec(
        getBaseXResliceEncoder(alphabet, bits),
        getBaseXResliceDecoder(alphabet, bits),
      )
      as VariableSizeCodec<String, String>;
}

/// Helper function to reslice the bits inside bytes.
List<int> _reslice(
  List<int> input,
  int inputBits,
  int outputBits,
  bool useRemainder,
) {
  final output = <int>[];
  var accumulator = 0;
  var bitsInAccumulator = 0;
  final mask = (1 << outputBits) - 1;
  for (final value in input) {
    accumulator = (accumulator << inputBits) | value;
    bitsInAccumulator += inputBits;
    while (bitsInAccumulator >= outputBits) {
      bitsInAccumulator -= outputBits;
      output.add((accumulator >> bitsInAccumulator) & mask);
    }
  }
  if (useRemainder && bitsInAccumulator > 0) {
    output.add((accumulator << (outputBits - bitsInAccumulator)) & mask);
  }
  return output;
}
