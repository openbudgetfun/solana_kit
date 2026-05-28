/// Byte array utilities for Solana data structures.
///
/// Provides efficient helpers for working with fixed-size byte arrays
/// (32-byte hashes, addresses, etc.) commonly used in Solana programs.
library;

import 'dart:typed_data';

/// Concatenates two byte arrays into a single [Uint8List].
///
/// This is more efficient than `Uint8List.fromList([...a, ...b])` because
/// it avoids creating intermediate lists.
Uint8List concatBytes(Uint8List a, Uint8List b) {
  final builder = BytesBuilder(copy: false)
    ..add(a)
    ..add(b);
  return builder.toBytes();
}

/// Concatenates multiple byte arrays into a single [Uint8List].
Uint8List concatAll(List<Uint8List> arrays) {
  final builder = BytesBuilder(copy: false);
  for (final array in arrays) {
    builder.add(array);
  }
  return builder.toBytes();
}

/// Creates a 32-byte array filled with zeros.
Uint8List zeroBytes32() => Uint8List(32);

/// Creates a 32-byte array from a hex string.
Uint8List bytes32FromHex(String hex) {
  if (hex.length != 64) {
    throw ArgumentError('Hex string must be exactly 64 characters (32 bytes)');
  }
  final bytes = Uint8List(32);
  for (var i = 0; i < 32; i++) {
    bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

/// Converts a 32-byte array to a hex string.
String bytes32ToHex(Uint8List bytes) {
  if (bytes.length != 32) {
    throw ArgumentError('Byte array must be exactly 32 bytes');
  }
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
