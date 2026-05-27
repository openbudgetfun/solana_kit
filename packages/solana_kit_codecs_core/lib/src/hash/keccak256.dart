// ignore_for_file: avoid_js_rounded_ints
/// Keccak-256 (not SHA3-256) hash function.
///
/// This implements the Keccak-256 hash as used by the Solana Account Compression
/// program and Metaplex Bubblegum. It uses **padding byte 0x01**,
/// not the 0x06 padding of NIST SHA3-256. These are completely different
/// hash functions despite similar internals.
///
/// ## Test vectors (cross-validated against hashlib)
///
/// ```text
/// keccak256('')     → c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
/// keccak256('abc')  → 4e03657aea45a94fc7d47ba826c8d667c0d1e6e33a64a036ec44f58fa12d6c45
/// ```
///
/// ## References
///
/// - FIPS 202 (SHA-3 standard) — defines the sponge construction
/// - [Wikipedia: SHA-3](https://en.wikipedia.org/wiki/SHA-3)
/// - [Keccak team](https://keccak.team/)
library;

import 'dart:typed_data';

/// The state size for Keccak-f[1600] in 64-bit lanes (25 lanes).
const _stateSize = 25;

/// The rate (in bytes) for Keccak-256.
///
/// Keccak-256 has an output of 256 bits, so capacity = 2 * 256 = 512 bits,
/// and rate = 1600 - 512 = 1088 bits = 136 bytes.
const _rateBytes = 136;

/// The rate in 64-bit lanes.
const _rateLanes = _rateBytes ~/ 8; // = 17

/// The Keccak-f[1600] round constants.
///
/// These 24 constants are used in the iota (ι) step of each round.
const _roundConstants = <int>[
  0x0000000000000001,
  0x0000000000008082,
  0x800000000000808A,
  0x8000000080008000,
  0x000000000000808B,
  0x0000000080000001,
  0x8000000080008081,
  0x8000000000008009,
  0x000000000000008A,
  0x0000000000000088,
  0x0000000080008009,
  0x000000008000000A,
  0x000000008000808B,
  0x800000000000008B,
  0x8000000000008089,
  0x8000000000008003,
  0x8000000000008002,
  0x8000000000000080,
  0x000000000000800A,
  0x800000008000000A,
  0x8000000080008081,
  0x8000000000008080,
  0x0000000080000001,
  0x8000000080008008,
];

/// Rotations for the rho (ρ) step.
const _rhoOffsets = <int>[
  0, 1, 62, 28, 27, // row 0
  36, 44, 6, 55, 20, // row 1
  3, 10, 43, 25, 39, // row 2
  41, 45, 15, 21, 8, // row 3
  18, 2, 61, 56, 14, // row 4
];

/// Mask for 64-bit integers.
const _mask64 = 0xFFFFFFFFFFFFFFFF;

/// Rotates a 64-bit integer left by [n] bits.
int _rotl64(int x, int n) {
  final nMod = n % 64;
  if (nMod == 0) return x;
  return ((x << nMod) | (x >>> (64 - nMod))) & _mask64;
}

/// The Keccak-f[1600] permutation.
///
/// Applies all 24 rounds to the state in place.
void _keccakF1600(List<int> state) {
  for (final roundConstant in _roundConstants) {
    // θ (theta) step
    final c = List<int>.filled(5, 0);
    for (var x = 0; x < 5; x++) {
      c[x] =
          state[x] ^
          state[x + 5] ^
          state[x + 10] ^
          state[x + 15] ^
          state[x + 20];
    }
    for (var x = 0; x < 5; x++) {
      final d = c[(x + 4) % 5] ^ _rotl64(c[(x + 1) % 5], 1);
      for (var y = 0; y < 5; y++) {
        state[5 * y + x] ^= d;
      }
    }

    // ρ (rho) and π (pi) steps combined
    final b = List<int>.filled(25, 0);
    for (var x = 0; x < 5; x++) {
      for (var y = 0; y < 5; y++) {
        b[5 * ((2 * x + 3 * y) % 5) + y] = _rotl64(
          state[5 * y + x],
          _rhoOffsets[5 * y + x],
        );
      }
    }

    // χ (chi) step
    for (var y = 0; y < 5; y++) {
      for (var x = 0; x < 5; x++) {
        state[5 * y + x] =
            b[5 * y + x] ^ ((~b[5 * y + (x + 1) % 5]) & b[5 * y + (x + 2) % 5]);
      }
    }

    // ι (iota) step
    state[0] ^= roundConstant;
  }
}

/// Reads 8 bytes from [input] at [offset] as a little-endian 64-bit integer.
int _bytesToLane(Uint8List input, int offset) {
  var result = 0;
  for (var i = 0; i < 8; i++) {
    result |= (input[offset + i] & 0xFF) << (8 * i);
  }
  return result & _mask64;
}

/// Writes a 64-bit integer [lane] to [output] at [offset] in little-endian.
void _laneToBytes(Uint8List output, int offset, int lane) {
  for (var i = 0; i < 8; i++) {
    output[offset + i] = (lane >> (8 * i)) & 0xFF;
  }
}

/// Computes the Keccak-256 hash of [input].
///
/// This is the Keccak-256 hash function as used by Solana's Account Compression
/// program and Metaplex Bubblegum. It uses padding byte **0x01**, making it
/// **different from SHA3-256** which uses padding byte 0x06.
///
/// Returns a 32-byte [Uint8List] containing the hash digest.
///
/// ## Example
///
/// ```dart
/// import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
///
/// void main() {
///   final hash = keccak256(Uint8List.fromList([0x61, 0x62, 0x63])); // "abc"
///   print(hash); // 4e0365...
/// }
/// ```
Uint8List keccak256(Uint8List input) {
  // Initialize state to all zeros
  final state = List<int>.filled(_stateSize, 0);

  // Absorb: process full rate blocks
  final fullBlockCount = input.length ~/ _rateBytes;
  for (var block = 0; block < fullBlockCount; block++) {
    final offset = block * _rateBytes;
    for (var i = 0; i < _rateLanes; i++) {
      state[i] ^= _bytesToLane(input, offset + i * 8);
    }
    _keccakF1600(state);
  }

  // Final padding block
  final temp = Uint8List(_rateBytes);
  final remaining = input.length - fullBlockCount * _rateBytes;
  for (var i = 0; i < remaining; i++) {
    temp[i] = input[fullBlockCount * _rateBytes + i];
  }
  // Keccak padding: 0x01 after message, 0x80 at the end
  temp[remaining] ^= 0x01;
  temp[_rateBytes - 1] ^= 0x80;

  for (var i = 0; i < _rateLanes; i++) {
    state[i] ^= _bytesToLane(temp, i * 8);
  }
  _keccakF1600(state);

  // Squeeze: output 32 bytes (4 lanes × 8 bytes each)
  final output = Uint8List(32);
  for (var i = 0; i < 4; i++) {
    _laneToBytes(output, i * 8, state[i]);
  }

  return output;
}
