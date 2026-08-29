/// Pure-Dart SHA-256 (FIPS 180-4) hash function.
///
/// The SPL Name Service hashes names with SHA-256 before deriving name
/// account addresses, so this package carries a small, dependency-free
/// implementation instead of pulling in an external crypto package.
///
/// ## Test vectors (FIPS 180-4 / NIST)
///
/// ```text
/// sha256('')    → e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
/// sha256('abc') → ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
/// ```
library;

import 'dart:typed_data';

/// The 64 round constants of SHA-256, the first 32 bits of the fractional
/// parts of the cube roots of the first 64 primes.
const List<int> _k = [
  0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, //
  0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
  0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
  0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
  0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
  0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
  0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
  0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
  0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
  0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
  0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

/// The initial hash values of SHA-256, the first 32 bits of the fractional
/// parts of the square roots of the first 8 primes.
const List<int> _h0 = [
  0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, //
  0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
];

int _rotr(int x, int n) {
  // Mask first so the shift inputs stay within 32 bits even though Dart ints
  // are 64-bit.
  final masked = x & 0xFFFFFFFF;
  return ((masked >>> n) | (masked << (32 - n))) & 0xFFFFFFFF;
}

/// Computes the SHA-256 digest of [data].
///
/// ```dart
/// final digest = sha256(utf8.encode('abc'));
/// hexEncode(digest); // ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb41…
/// ```
Uint8List sha256(Uint8List data) {
  final bitLength = data.length * 8;

  // Pad the message: 0x80, zeros, then the 64-bit big-endian bit length so
  // the total length is a multiple of 64 bytes.
  final paddedLength = ((data.length + 8) ~/ 64 + 1) * 64;
  final padded = Uint8List(paddedLength)..setRange(0, data.length, data);
  padded[data.length] = 0x80;
  for (var i = 0; i < 8; i++) {
    padded[paddedLength - 1 - i] = bitLength >>> (8 * i) & 0xFF;
  }

  final hash = List<int>.from(_h0);
  final w = List<int>.filled(64, 0);

  for (var block = 0; block < paddedLength; block += 64) {
    for (var t = 0; t < 16; t++) {
      final i = block + t * 4;
      w[t] =
          (padded[i] << 24) |
          (padded[i + 1] << 16) |
          (padded[i + 2] << 8) |
          padded[i + 3];
    }
    for (var t = 16; t < 64; t++) {
      final s0 = _rotr(w[t - 15], 7) ^ _rotr(w[t - 15], 18) ^ (w[t - 15] >>> 3);
      final s1 = _rotr(w[t - 2], 17) ^ _rotr(w[t - 2], 19) ^ (w[t - 2] >>> 10);
      w[t] = (w[t - 16] + s0 + w[t - 7] + s1) & 0xFFFFFFFF;
    }

    var a = hash[0];
    var b = hash[1];
    var c = hash[2];
    var d = hash[3];
    var e = hash[4];
    var f = hash[5];
    var g = hash[6];
    var h = hash[7];

    for (var t = 0; t < 64; t++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ (~e & g);
      final temp1 = (h + s1 + ch + _k[t] + w[t]) & 0xFFFFFFFF;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + maj) & 0xFFFFFFFF;

      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xFFFFFFFF;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xFFFFFFFF;
    }

    hash[0] = (hash[0] + a) & 0xFFFFFFFF;
    hash[1] = (hash[1] + b) & 0xFFFFFFFF;
    hash[2] = (hash[2] + c) & 0xFFFFFFFF;
    hash[3] = (hash[3] + d) & 0xFFFFFFFF;
    hash[4] = (hash[4] + e) & 0xFFFFFFFF;
    hash[5] = (hash[5] + f) & 0xFFFFFFFF;
    hash[6] = (hash[6] + g) & 0xFFFFFFFF;
    hash[7] = (hash[7] + h) & 0xFFFFFFFF;
  }

  final digest = Uint8List(32);
  for (var i = 0; i < 8; i++) {
    digest[i * 4] = hash[i] >>> 24 & 0xFF;
    digest[i * 4 + 1] = hash[i] >>> 16 & 0xFF;
    digest[i * 4 + 2] = hash[i] >>> 8 & 0xFF;
    digest[i * 4 + 3] = hash[i] & 0xFF;
  }
  return digest;
}
