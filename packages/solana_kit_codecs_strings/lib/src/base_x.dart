import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_strings/src/assertions.dart';

/// Returns an encoder for base-X encoded strings.
///
/// This encoder serializes strings using a custom alphabet, treating the
/// length of the alphabet as the base. The encoding process involves
/// converting the input string to a numeric value in base-X, then encoding
/// that value into bytes while preserving leading zeroes.
///
/// For more details, see [getBaseXCodec].
VariableSizeEncoder<String> getBaseXEncoder(String alphabet) {
  return VariableSizeEncoder<String>(
    getSizeFromValue: (value) {
      final (leadingZeroes, tailChars) = _partitionLeadingZeroes(
        value,
        alphabet[0],
      );
      if (tailChars == null || tailChars.isEmpty) return value.length;

      final base10Number = _getBigIntFromBaseX(tailChars, alphabet);
      return leadingZeroes.length +
          (base10Number.toRadixString(16).length / 2).ceil();
    },
    write: (value, bytes, offset) {
      // Check if the value is valid.
      assertValidBaseString(alphabet, value);
      if (value.isEmpty) return offset;

      // Handle leading zeroes.
      final (leadingZeroes, tailChars) = _partitionLeadingZeroes(
        value,
        alphabet[0],
      );
      if (tailChars == null || tailChars.isEmpty) {
        for (var i = 0; i < leadingZeroes.length; i++) {
          bytes[offset + i] = 0;
        }
        return offset + leadingZeroes.length;
      }

      // From baseX to base10.
      var base10Number = _getBigIntFromBaseX(tailChars, alphabet);

      // From base10 to bytes.
      final tailBytes = <int>[];
      while (base10Number > BigInt.zero) {
        tailBytes.insert(0, (base10Number % BigInt.from(256)).toInt());
        base10Number = base10Number ~/ BigInt.from(256);
      }

      final bytesToAdd = [
        ...List<int>.filled(leadingZeroes.length, 0),
        ...tailBytes,
      ];
      bytes.setAll(offset, bytesToAdd);
      return offset + bytesToAdd.length;
    },
  );
}

/// Returns a decoder for base-X encoded strings.
///
/// This decoder deserializes base-X encoded strings from a byte array using
/// a custom alphabet. The decoding process converts the byte array into a
/// numeric value in base-10, then maps that value back to characters in the
/// specified base-X alphabet.
///
/// For more details, see [getBaseXCodec].
VariableSizeDecoder<String> getBaseXDecoder(String alphabet) {
  return VariableSizeDecoder<String>(
    read: (rawBytes, offset) {
      final bytes = offset == 0 ? rawBytes : rawBytes.sublist(offset);
      if (bytes.isEmpty) return ('', offset);

      // Handle leading zeroes.
      var trailIndex = bytes.indexWhere((n) => n != 0);
      if (trailIndex == -1) trailIndex = bytes.length;
      final leadingZeroes = alphabet[0] * trailIndex;
      if (trailIndex == bytes.length) return (leadingZeroes, rawBytes.length);

      // From bytes to base10.
      final base10Number = bytes.sublist(trailIndex).fold<BigInt>(BigInt.zero, (
        sum,
        byte,
      ) {
        return sum * BigInt.from(256) + BigInt.from(byte);
      });

      // From base10 to baseX.
      final tailChars = _getBaseXFromBigInt(base10Number, alphabet);

      return (leadingZeroes + tailChars, rawBytes.length);
    },
  );
}

/// Returns a codec for encoding and decoding base-X strings.
///
/// This codec serializes strings using a custom alphabet, treating the
/// length of the alphabet as the base.
///
/// This codec supports leading zeroes by treating the first character of
/// the alphabet as the zero character.
VariableSizeCodec<String, String> getBaseXCodec(String alphabet) {
  return combineCodec(getBaseXEncoder(alphabet), getBaseXDecoder(alphabet))
      as VariableSizeCodec<String, String>;
}

/// Splits a string into leading zero characters and the remaining tail.
(String leadingZeroes, String? tailChars) _partitionLeadingZeroes(
  String value,
  String zeroCharacter,
) {
  var i = 0;
  while (i < value.length && value[i] == zeroCharacter) {
    i++;
  }
  final leadingZeroes = value.substring(0, i);
  final tailChars = i < value.length ? value.substring(i) : null;
  return (leadingZeroes, tailChars);
}

/// Converts a base-X string to a BigInt using the given alphabet.
BigInt _getBigIntFromBaseX(String value, String alphabet) {
  final base = BigInt.from(alphabet.length);
  var sum = BigInt.zero;
  for (var i = 0; i < value.length; i++) {
    sum = sum * base + BigInt.from(alphabet.indexOf(value[i]));
  }
  return sum;
}

/// Converts a BigInt to a base-X string using the given alphabet.
String _getBaseXFromBigInt(BigInt value, String alphabet) {
  final base = BigInt.from(alphabet.length);
  final tailChars = <String>[];
  var remaining = value;
  while (remaining > BigInt.zero) {
    tailChars.insert(0, alphabet[(remaining % base).toInt()]);
    remaining = remaining ~/ base;
  }
  return tailChars.join();
}
