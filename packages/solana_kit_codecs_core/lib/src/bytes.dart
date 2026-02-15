import 'dart:typed_data';

/// Concatenates a list of [Uint8List]s into a single [Uint8List].
///
/// Reuses the original byte array when only one non-empty array is present.
Uint8List mergeBytes(List<Uint8List> byteArrays) {
  final nonEmpty = byteArrays.where((arr) => arr.isNotEmpty).toList();
  if (nonEmpty.isEmpty) {
    return byteArrays.isNotEmpty ? byteArrays[0] : Uint8List(0);
  }
  if (nonEmpty.length == 1) {
    return nonEmpty[0];
  }
  final totalLength = nonEmpty.fold<int>(0, (sum, arr) => sum + arr.length);
  final result = Uint8List(totalLength)
    ..setAll(0, nonEmpty.expand((arr) => arr));
  return result;
}

/// Pads [bytes] with trailing zeroes to reach [length].
///
/// If [bytes] is already at or exceeds [length], it is returned as-is.
Uint8List padBytes(Uint8List bytes, int length) {
  if (bytes.length >= length) return bytes;
  final padded = Uint8List(length)..setAll(0, bytes);
  return padded;
}

/// Fixes [bytes] to exactly [length] bytes.
///
/// - If shorter, pads with trailing zeroes.
/// - If longer, truncates.
/// - If already the right length, returns as-is.
Uint8List fixBytes(Uint8List bytes, int length) {
  if (bytes.length == length) return bytes;
  final source = bytes.length <= length ? bytes : bytes.sublist(0, length);
  return padBytes(source, length);
}

/// Returns `true` if [data] contains [bytes] at the given [offset].
bool containsBytes(Uint8List data, Uint8List bytes, int offset) {
  if (offset + bytes.length > data.length) return false;
  final slice = offset == 0 && data.length == bytes.length
      ? data
      : data.sublist(offset, offset + bytes.length);
  return bytesEqual(slice, bytes);
}

/// Returns `true` if [bytes1] and [bytes2] are element-wise equal.
bool bytesEqual(Uint8List bytes1, Uint8List bytes2) {
  if (bytes1.length != bytes2.length) return false;
  for (var i = 0; i < bytes1.length; i++) {
    if (bytes1[i] != bytes2[i]) return false;
  }
  return true;
}
