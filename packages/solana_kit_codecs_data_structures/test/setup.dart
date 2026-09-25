import 'dart:typed_data';

/// Converts a hex string into a [Uint8List].
///
/// Example: `b('010203')` returns `Uint8List.fromList([1, 2, 3])`.
Uint8List b(String hex) {
  if (hex.isEmpty) return Uint8List(0);
  final bytes = <int>[];
  for (var i = 0; i < hex.length; i += 2) {
    bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
  }
  return Uint8List.fromList(bytes);
}

/// Converts a [Uint8List] to a hex string.
String hex(Uint8List bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
