import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';

/// Returns an encoder that packs an array of booleans into bits.
///
/// This encoder converts a list of `bool` values into a compact bit
/// representation, storing 8 booleans per byte.
///
/// The [backward] option determines whether the bits are stored in
/// MSB-first (`false`, the default) or LSB-first (`true`).
FixedSizeEncoder<List<bool>> getBitArrayEncoder(
  int size, {
  bool backward = false,
}) {
  return FixedSizeEncoder<List<bool>>(
    fixedSize: size,
    write: (List<bool> value, Uint8List bytes, int offset) {
      final bytesToAdd = <int>[];

      for (var i = 0; i < size; i++) {
        var byte = 0;
        for (var j = 0; j < 8; j++) {
          final index = i * 8 + j;
          final feature = index < value.length && value[index] ? 1 : 0;
          if (backward) {
            byte |= feature << j;
          } else {
            byte |= feature << (7 - j);
          }
        }
        if (backward) {
          bytesToAdd.insert(0, byte);
        } else {
          bytesToAdd.add(byte);
        }
      }

      bytes.setAll(offset, bytesToAdd);
      return offset + size;
    },
  );
}

/// Returns a decoder that unpacks bits into an array of booleans.
///
/// This decoder converts a compact bit representation back into a list of
/// `bool` values. Each byte is expanded into 8 booleans.
///
/// The [backward] option determines whether the bits are read in
/// MSB-first (`false`, the default) or LSB-first (`true`).
FixedSizeDecoder<List<bool>> getBitArrayDecoder(
  int size, {
  bool backward = false,
}) {
  return FixedSizeDecoder<List<bool>>(
    fixedSize: size,
    read: (Uint8List bytes, int offset) {
      assertByteArrayHasEnoughBytesForCodec('bitArray', size, bytes, offset);
      final booleans = <bool>[];
      var slice = bytes.sublist(offset, offset + size);
      if (backward) {
        slice = Uint8List.fromList(slice.reversed.toList());
      }

      for (final rawByte in slice) {
        var byte = rawByte;
        for (var i = 0; i < 8; i++) {
          if (backward) {
            booleans.add((byte & 1) != 0);
            byte >>= 1;
          } else {
            booleans.add((byte & 0x80) != 0);
            byte <<= 1;
            byte &= 0xFF; // Keep it as an unsigned byte.
          }
        }
      }

      return (booleans, offset + size);
    },
  );
}

/// Returns a codec that encodes and decodes boolean arrays as compact bit
/// representations.
///
/// This codec efficiently stores boolean arrays as bits, packing 8 values
/// per byte.
FixedSizeCodec<List<bool>, List<bool>> getBitArrayCodec(
  int size, {
  bool backward = false,
}) {
  return combineCodec(
        getBitArrayEncoder(size, backward: backward),
        getBitArrayDecoder(size, backward: backward),
      )
      as FixedSizeCodec<List<bool>, List<bool>>;
}
