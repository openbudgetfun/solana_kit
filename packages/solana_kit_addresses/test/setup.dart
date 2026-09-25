import 'dart:typed_data';

/// Encode hex string to [Uint8List].
Uint8List b(String hex) {
  if (hex.isEmpty) return Uint8List(0);
  final matches = RegExp('.{1,2}').allMatches(hex.toLowerCase());
  return Uint8List.fromList(
    matches.map((m) => int.parse(m.group(0)!, radix: 16)).toList(),
  );
}

/// Decode [Uint8List] to lowercase hex string.
String h(Uint8List bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
