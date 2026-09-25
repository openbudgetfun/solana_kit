import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

import 'package:solana_kit_codecs_strings/src/assertions.dart';
import 'package:solana_kit_codecs_strings/src/base_x_lookup.dart';

/// Returns an encoder for base-X encoded strings.
///
/// This encoder serializes strings using a custom alphabet, treating the
/// length of the alphabet as the base. The encoding process involves
/// converting the input string to a numeric value in base-X, then encoding
/// that value into bytes while preserving leading zeroes.
///
/// For more details, see [getBaseXCodec].
///
/// Throws an [ArgumentError] when [alphabet] cannot represent a base-X
/// encoding (fewer than two characters), so a misconfigured alphabet fails
/// where it is declared rather than on the first encoded value.
VariableSizeEncoder<String> getBaseXEncoder(String alphabet) {
  baseXLookupFor(alphabet);
  return VariableSizeEncoder<String>(
    getSizeFromValue: (value) => _convertToBytes(value, alphabet).byteLength,
    write: (value, bytes, offset) {
      // Check if the value is valid.
      assertValidBaseString(alphabet, value);
      if (value.isEmpty) return offset;

      final converted = _convertToBytes(value, alphabet);
      final zeroBytes = converted.leadingZeroes;
      bytes
        ..fillRange(offset, offset + zeroBytes, 0)
        ..setAll(offset + zeroBytes, converted.bytes);
      return offset + zeroBytes + converted.bytes.length;
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
///
/// Throws an [ArgumentError] when [alphabet] cannot represent a base-X
/// encoding (fewer than two characters), so a misconfigured alphabet fails
/// where it is declared rather than on the first decoded value.
VariableSizeDecoder<String> getBaseXDecoder(String alphabet) {
  baseXLookupFor(alphabet);
  return VariableSizeDecoder<String>(
    read: (rawBytes, offset) {
      final lookup = baseXLookupFor(alphabet);
      final bytes = offset == 0 || offset <= -rawBytes.length
          ? rawBytes
          : rawBytes.sublist(offset);
      if (bytes.isEmpty) return ('', rawBytes.length);

      // Handle leading zeroes.
      var trailIndex = bytes.indexWhere((n) => n != 0);
      if (trailIndex == -1) trailIndex = bytes.length;
      if (trailIndex == bytes.length) {
        return (lookup.zeroCharacter * bytes.length, rawBytes.length);
      }

      final tailChars = _convertToBaseX(bytes, trailIndex, lookup);
      return (lookup.zeroCharacter * trailIndex + tailChars, rawBytes.length);
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

/// A base-X string converted to its byte representation.
class _ConvertedBytes {
  const _ConvertedBytes({required this.leadingZeroes, required this.bytes});

  /// How many leading zero bytes the value encodes to.
  final int leadingZeroes;

  /// The significant bytes, big-endian, with no leading zero bytes.
  final Uint8List bytes;

  /// The total encoded length, which is what [VariableSizeEncoder.encode]
  /// allocates for.
  int get byteLength => leadingZeroes + bytes.length;
}

/// Converts a base-X string to bytes using word-sized arithmetic.
///
/// Each alphabet character is folded into a little-endian byte buffer one
/// digit at a time, carrying within a single machine integer. The significant
/// bytes are returned big-endian with leading zero bytes trimmed, which is the
/// same minimal big-endian representation a big-integer conversion produces.
///
/// Characters outside the alphabet contribute a digit of `0` so this stays
/// total for callers that skip validation; [assertValidBaseString] is the
/// validating entry point.
_ConvertedBytes _convertToBytes(String value, String alphabet) {
  final lookup = baseXLookupFor(alphabet);
  final base = lookup.base;
  final zeroCharacter = alphabet.codeUnitAt(0);

  var firstSignificant = 0;
  while (firstSignificant < value.length &&
      value.codeUnitAt(firstSignificant) == zeroCharacter) {
    firstSignificant++;
  }
  final leadingZeroes = firstSignificant;
  if (leadingZeroes == value.length) {
    return _ConvertedBytes(leadingZeroes: leadingZeroes, bytes: _noBytes);
  }

  final significant = value.length - leadingZeroes;
  final buffer = Uint8List(lookup.bytesForCharacters(significant) + 1);
  var length = 0;

  for (var i = leadingZeroes; i < value.length; i++) {
    var carry = lookup.indexOf(value.codeUnitAt(i));
    if (carry < 0) carry = 0;
    var j = 0;
    for (; carry != 0 || j < length; j++) {
      carry += base * buffer[j];
      buffer[j] = carry & 0xff;
      carry >>= 8;
    }
    length = j;
  }

  // Little-endian buffer, big-endian output. The carry loop above always
  // leaves the highest written byte non-zero: zero-valued leading characters
  // were stripped before folding, so the first digit is never zero, and the
  // loop only stops once the carry is exhausted. The result is therefore
  // already the minimal big-endian representation.
  final bytes = Uint8List(length);
  for (var i = 0; i < length; i++) {
    bytes[i] = buffer[length - 1 - i];
  }
  return _ConvertedBytes(leadingZeroes: leadingZeroes, bytes: bytes);
}

/// Converts bytes from [start] onwards into base-X characters.
///
/// Bytes are folded into a little-endian digit buffer one at a time, carrying
/// within a single machine integer, then mapped through the alphabet in
/// most-significant-first order.
String _convertToBaseX(Uint8List bytes, int start, BaseXLookup lookup) {
  final byteCount = bytes.length - start;
  final base = lookup.base;
  final buffer = Uint32List(lookup.digitsForBytes(byteCount) + 1);
  var length = 0;

  for (var i = start; i < bytes.length; i++) {
    var carry = bytes[i];
    var j = 0;
    for (; carry != 0 || j < length; j++) {
      carry += 256 * buffer[j];
      buffer[j] = carry % base;
      carry ~/= base;
    }
    length = j;
  }

  // Every slot below [length] holds a digit in `[0, base)`, so the alphabet
  // index is always in range.
  final chars = Uint16List(length);
  for (var i = 0; i < length; i++) {
    chars[i] = lookup.alphabet.codeUnitAt(buffer[length - 1 - i]);
  }
  return String.fromCharCodes(chars);
}

final _noBytes = Uint8List(0);
