import 'dart:typed_data';

/// A pure-Dart SHA-256 implementation (FIPS 180-4).
///
/// Anchor program discriminators are the first eight bytes of
/// `sha256("<namespace>:<name>")`, so this package needs a SHA-256 without
/// pulling in a platform crypto dependency, mirroring the hand-written
/// Keccak-256 in `solana_kit_codecs_core`.
///
/// All API calls assert valid inputs.
Uint8List sha256(List<int> input) {
  if (input.any((byte) => byte < 0 || byte > 0xff)) {
    throw ArgumentError.value(
      input.firstWhere((byte) => byte < 0 || byte > 0xff),
      'input',
      'SHA-256 input bytes must be in the range 0..255',
    );
  }
  return _compress(input);
}

// ---------------------------------------------------------------------------
// FIPS 180-4 constants
// ---------------------------------------------------------------------------

const List<int> _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, //
  0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
  0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
  0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
  0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
  0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
  0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
  0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
  0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
  0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
  0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

Uint8List _compress(List<int> input) {
  final messageLengthBits = input.length * 8;
  final padded = List<int>.from(input)..add(0x80);
  while (padded.length % 64 != 56) {
    padded.add(0x00);
  }
  for (var i = 7; i >= 0; i--) {
    padded.add((messageLengthBits >> (i * 8)) & 0xff);
  }

  var h0 = 0x6a09e667;
  var h1 = 0xbb67ae85;
  var h2 = 0x3c6ef372;
  var h3 = 0xa54ff53a;
  var h4 = 0x510e527f;
  var h5 = 0x9b05688c;
  var h6 = 0x1f83d9ab;
  var h7 = 0x5be0cd19;

  for (var block = 0; block < padded.length; block += 64) {
    final w = List<int>.filled(64, 0);
    for (var i = 0; i < 16; i++) {
      final base = block + i * 4;
      w[i] =
          (padded[base] << 24) |
          (padded[base + 1] << 16) |
          (padded[base + 2] << 8) |
          padded[base + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = _mask32(w[i - 16] + s0 + w[i - 7] + s1);
    }

    var a = h0;
    var b = h1;
    var c = h2;
    var d = h3;
    var e = h4;
    var f = h5;
    var g = h6;
    var h = h7;

    for (var i = 0; i < 64; i++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ (~e & g);
      final temp1 = _mask32(h + s1 + ch + _k[i] + w[i]);
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = _mask32(s0 + maj);
      h = g;
      g = f;
      f = e;
      e = _mask32(d + temp1);
      d = c;
      c = b;
      b = a;
      a = _mask32(temp1 + temp2);
    }
    h0 = _mask32(h0 + a);
    h1 = _mask32(h1 + b);
    h2 = _mask32(h2 + c);
    h3 = _mask32(h3 + d);
    h4 = _mask32(h4 + e);
    h5 = _mask32(h5 + f);
    h6 = _mask32(h6 + g);
    h7 = _mask32(h7 + h);
  }

  final digest = Uint8List(32);
  for (final (index, word) in [h0, h1, h2, h3, h4, h5, h6, h7].indexed) {
    digest[index * 4] = (word >> 24) & 0xff;
    digest[index * 4 + 1] = (word >> 16) & 0xff;
    digest[index * 4 + 2] = (word >> 8) & 0xff;
    digest[index * 4 + 3] = word & 0xff;
  }
  return digest;
}

int _mask32(int value) => value & 0xffffffff;

int _rotr(int value, int amount) =>
    ((value >> amount) | (value << (32 - amount))) & 0xffffffff;
