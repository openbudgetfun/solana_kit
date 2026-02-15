import 'dart:typed_data';

import 'package:solana_kit_addresses/src/address.dart';
import 'package:solana_kit_addresses/src/address_codec.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

// ---------------------------------------------------------------------------
// Ed25519 curve constants
// ---------------------------------------------------------------------------

/// The prime field: p = 2^255 - 19
final BigInt _p = BigInt.two.pow(255) - BigInt.from(19);

/// The Ed25519 curve parameter d.
final BigInt _d = BigInt.parse(
  '37095705934669439343138083508754565189542113879843219016388785533085940283555',
);

/// Square root of -1 modulo p.
final BigInt _rm1 = BigInt.parse(
  '19681161376707505956807079304988542015446066515923890162744021073123829784752',
);

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/// Returns `true` if the given 32 [bytes] represent a compressed point that
/// lies on the Ed25519 curve.
///
/// Returns `false` if [bytes] is not exactly 32 bytes long or if the point
/// is not on the curve.
bool compressedPointBytesAreOnCurve(Uint8List bytes) {
  if (bytes.length != 32) return false;
  final y = _decompressPointBytes(bytes);
  return _pointIsOnCurve(y, bytes[31]);
}

/// Returns `true` if the given [addr] decodes to a point on the Ed25519
/// curve.
bool isOnCurveAddress(Address addr) {
  final addressBytes = getAddressCodec().encode(addr);
  return compressedPointBytesAreOnCurve(addressBytes);
}

/// Returns `true` if the given [addr] decodes to a point that is NOT on the
/// Ed25519 curve.
bool isOffCurveAddress(Address addr) {
  return !isOnCurveAddress(addr);
}

/// Asserts that the given [addr] is on the Ed25519 curve.
///
/// Throws [SolanaError] with [SolanaErrorCode.addressesInvalidEd25519PublicKey]
/// if the address is not on the curve.
void assertIsOnCurveAddress(Address addr) {
  if (!isOnCurveAddress(addr)) {
    throw SolanaError(SolanaErrorCode.addressesInvalidEd25519PublicKey);
  }
}

/// Asserts that the given [addr] is NOT on the Ed25519 curve.
///
/// Throws [SolanaError] with [SolanaErrorCode.addressesInvalidOffCurveAddress]
/// if the address is on the curve.
void assertIsOffCurveAddress(Address addr) {
  if (!isOffCurveAddress(addr)) {
    throw SolanaError(SolanaErrorCode.addressesInvalidOffCurveAddress, {
      'putativeOffCurveAddress': addr.value,
    });
  }
}

// ---------------------------------------------------------------------------
// Internal Ed25519 implementation (ported from noble-ed25519)
// ---------------------------------------------------------------------------

/// Decompresses the 32-byte compressed point representation to get the y
/// coordinate as a [BigInt].
BigInt _decompressPointBytes(Uint8List bytes) {
  // Read the 32 bytes in little-endian order, clearing the sign bit on the
  // last byte.
  final hexString = StringBuffer();
  for (var i = 31; i >= 0; i--) {
    final byte = i == 31 ? bytes[i] & 0x7f : bytes[i];
    hexString.write(byte.toRadixString(16).padLeft(2, '0'));
  }
  return BigInt.parse('0x$hexString');
}

/// Modular reduction: returns `a mod p` with positive result.
BigInt _mod(BigInt a) {
  final r = a % _p;
  return r >= BigInt.zero ? r : _p + r;
}

/// Computes `x^(2^power) mod p`.
BigInt _pow2(BigInt x, int power) {
  var r = x;
  for (var i = 0; i < power; i++) {
    r = r * r % _p;
  }
  return r;
}

/// Computes `x^(2^252 - 3) mod p` using the unrolled addition chain.
BigInt _pow2523(BigInt x) {
  final x2 = x * x % _p;
  final b2 = x2 * x % _p;
  final b4 = _pow2(b2, 2) * b2 % _p;
  final b5 = _pow2(b4, 1) * x % _p;
  final b10 = _pow2(b5, 5) * b5 % _p;
  final b20 = _pow2(b10, 10) * b10 % _p;
  final b40 = _pow2(b20, 20) * b20 % _p;
  final b80 = _pow2(b40, 40) * b40 % _p;
  final b160 = _pow2(b80, 80) * b80 % _p;
  final b240 = _pow2(b160, 80) * b80 % _p;
  final b250 = _pow2(b240, 10) * b10 % _p;
  return _pow2(b250, 2) * x % _p;
}

/// Computes the UV ratio for square root computation.
/// Returns the root if it exists, or `null` if no valid root exists.
BigInt? _uvRatio(BigInt u, BigInt v) {
  final v3 = _mod(v * v * v);
  final v7 = _mod(v3 * v3 * v);
  final pow = _pow2523(u * v7);
  var x = _mod(u * v3 * pow);
  final vx2 = _mod(v * x * x);
  final root1 = x;
  final root2 = _mod(x * _rm1);
  final useRoot1 = vx2 == u;
  final useRoot2 = vx2 == _mod(-u);
  // Used below to select root2 for constant-time behavior matching noble-ed25519.
  // ignore: unused_local_variable
  final noRoot = vx2 == _mod(-u * _rm1);
  if (useRoot1) x = root1;
  if (useRoot2 || noRoot) x = root2;
  if ((_mod(x) & BigInt.one) == BigInt.one) x = _mod(-x);
  if (!useRoot1 && !useRoot2) {
    return null;
  }
  return x;
}

/// Returns `true` if the given y coordinate and last byte represent a valid
/// point on the Ed25519 curve.
bool _pointIsOnCurve(BigInt y, int lastByte) {
  final y2 = _mod(y * y);
  final u = _mod(y2 - BigInt.one);
  final v = _mod(_d * y2 + BigInt.one);
  final x = _uvRatio(u, v);
  if (x == null) return false;
  final isLastByteOdd = (lastByte & 0x80) != 0;
  if (x == BigInt.zero && isLastByteOdd) return false;
  return true;
}
