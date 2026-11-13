import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:solana_kit_privacy_rings/src/exception.dart';

final BigInt _p = BigInt.parse(
  'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffeffffffff0000000000000000ffffffff',
  radix: 16,
);
final BigInt _b = BigInt.parse(
  'b3312fa7e23ee7e4988e056be3f82d19181d9c6efe8141120314088f5013875ac656398d8a2ed19d2a85c8edd3ec2aef',
  radix: 16,
);
final BigInt _n = BigInt.parse(
  'ffffffffffffffffffffffffffffffffffffffffffffffffc7634d81f4372ddf581a0db248b0a77aecec196accc52973',
  radix: 16,
);
final BigInt _gx = BigInt.parse(
  'aa87ca22be8b05378eb1c71ef320ad746e1d3b628ba79b9859f741e082542a385502f25dbf55296c3a545e3872760ab7',
  radix: 16,
);
final BigInt _gy = BigInt.parse(
  '3617de4a96262c6f5d9e98bf9292dc29f8f41dbd289a147ce9da3113b5f0b8c00a60b1ce1d7e819d7a431d7c90ea0e5f',
  radix: 16,
);

/// Verifies an ECDSA P-384 SHA-384 signature.
///
/// [signature] is `r || s` when [der] is false, and an ASN.1 sequence of
/// two integers when [der] is true. High `s` is accepted. A malformed
/// signature or a point off the curve returns false.
bool p384Verify(
  List<int> signature,
  List<int> message,
  List<int> publicKey, {
  required bool der,
}) {
  final point = _point(publicKey);
  if (point == null) return false;
  final pair = der ? _derSignature(signature) : _compactSignature(signature);
  if (pair == null) return false;
  final digest = sha384.convert(message).bytes;
  var e = BigInt.zero;
  for (final byte in digest) {
    e = (e << 8) | BigInt.from(byte);
  }
  e %= _n;
  final w = pair.$2.modInverse(_n);
  final u1 = (e * w) % _n;
  final u2 = (pair.$1 * w) % _n;
  final sum = _add(_mul(_gx, _gy, u1), _mul(point.$1, point.$2, u2));
  if (sum == null) return false;
  return sum.$1 % _n == pair.$1;
}

/// Uncompressed P-384 public key for generating test certificates.
///
/// Internal variable-time arithmetic; not exported as a signing API.
Uint8List p384PublicKey(List<int> secret) {
  if (secret.length != 48) {
    throw PrivacyRingsException(
      'a P-384 secret is ${secret.length} bytes',
      code: 'invalid_length',
    );
  }
  final d = _unsigned(secret) % _n;
  if (d == BigInt.zero) {
    throw PrivacyRingsException(
      'a P-384 secret is outside the curve order',
      code: 'integer_range',
    );
  }
  final point = _mul(_gx, _gy, d)!;
  return Uint8List.fromList([
    0x04,
    ..._fixed(point.$1, 48),
    ..._fixed(point.$2, 48),
  ]);
}

/// Signs [message] with a 48-byte scalar [secret] for test attestations.
///
/// Internal variable-time arithmetic; not exported as a signing API.
///
/// The result is compact `r || s`. [nonce] fixes `k` so a test can
/// reproduce a signature. A zero `r` or `s` draws another nonce.
Uint8List p384Sign(
  List<int> message,
  List<int> secret, {
  List<int>? nonce,
}) {
  if (secret.length != 48) {
    throw PrivacyRingsException(
      'a P-384 secret is ${secret.length} bytes',
      code: 'invalid_length',
    );
  }
  final d = _unsigned(secret) % _n;
  if (d == BigInt.zero) {
    throw PrivacyRingsException(
      'a P-384 secret is outside the curve order',
      code: 'integer_range',
    );
  }
  final digest = sha384.convert(message).bytes;
  var e = BigInt.zero;
  for (final byte in digest) {
    e = (e << 8) | BigInt.from(byte);
  }
  e %= _n;
  final fixed = nonce == null ? null : Uint8List.fromList(nonce);
  for (var attempt = 0; attempt < 8; attempt++) {
    final kBytes = fixed ?? _random(48);
    final k = _unsigned(kBytes) % _n;
    if (k == BigInt.zero) continue;
    final point = _mul(_gx, _gy, k)!;
    final r = point.$1 % _n;
    if (r == BigInt.zero) continue;
    final s = (k.modInverse(_n) * ((e + r * d) % _n)) % _n;
    if (s == BigInt.zero) continue;
    return Uint8List.fromList([..._fixed(r, 48), ..._fixed(s, 48)]);
  }
  throw PrivacyRingsException(
    'P-384 signing did not find a nonce',
    code: 'tee_encryption',
  );
}

(BigInt, BigInt)? _point(List<int> bytes) {
  if (bytes.length != 97 || bytes[0] != 0x04) return null;
  final x = _unsigned(bytes.sublist(1, 49));
  final y = _unsigned(bytes.sublist(49, 97));
  if (x >= _p || y >= _p) return null;
  final yy = _mod(y * y, _p);
  final curve = _mod(
    _mod(x * x, _p) * x - BigInt.from(3) * x + _b,
    _p,
  );
  if (yy != curve) return null;
  return (x, y);
}

(BigInt, BigInt)? _compactSignature(List<int> bytes) {
  if (bytes.length != 96) return null;
  final r = _unsigned(bytes.sublist(0, 48));
  final s = _unsigned(bytes.sublist(48, 96));
  if (r == BigInt.zero || s == BigInt.zero || r >= _n || s >= _n) {
    return null;
  }
  return (r, s);
}

(BigInt, BigInt)? _derSignature(List<int> bytes) {
  if (bytes.length < 8 || bytes[0] != 0x30) return null;
  final length = _derLength(bytes, 1);
  if (length == null || length.$2 != bytes.length) return null;
  var offset = length.$1;
  final r = _derInt(bytes, offset);
  if (r == null) return null;
  offset = r.$2;
  final s = _derInt(bytes, offset);
  if (s == null || s.$2 != bytes.length) return null;
  if (r.$1 == BigInt.zero || s.$1 == BigInt.zero || r.$1 >= _n || s.$1 >= _n) {
    return null;
  }
  return (r.$1, s.$1);
}

(int, int)? _derLength(List<int> bytes, int offset) {
  if (offset >= bytes.length) return null;
  final first = bytes[offset];
  if (first < 0x80) return (offset + 1, offset + 1 + first);
  final count = first & 0x7f;
  if (count == 0 || count > 2 || offset + 1 + count > bytes.length) {
    return null;
  }
  var length = 0;
  for (var i = 0; i < count; i++) {
    length = (length << 8) | bytes[offset + 1 + i];
  }
  final start = offset + 1 + count;
  if (start + length > bytes.length) return null;
  return (start, start + length);
}

(BigInt, int)? _derInt(List<int> bytes, int offset) {
  if (offset + 2 > bytes.length || bytes[offset] != 0x02) return null;
  final length = bytes[offset + 1];
  if (length == 0 || offset + 2 + length > bytes.length) return null;
  final body = bytes.sublist(offset + 2, offset + 2 + length);
  if (body[0] & 0x80 != 0) return null;
  if (body.length > 1 && body[0] == 0 && body[1] & 0x80 == 0) return null;
  return (_unsigned(body), offset + 2 + length);
}

(BigInt, BigInt)? _add((BigInt, BigInt)? left, (BigInt, BigInt)? right) {
  if (left == null) return right;
  if (left.$1 == right!.$1) {
    final reflected = _mod(left.$2 + right.$2, _p);
    if (reflected == BigInt.zero) return null;
    return _double(left);
  }
  final slope = _mod(
    _mod(right.$2 - left.$2, _p) * _mod(right.$1 - left.$1, _p).modInverse(_p),
    _p,
  );
  return _apply(left, right.$1, slope);
}

(BigInt, BigInt) _double((BigInt, BigInt) point) {
  final slope = _mod(
    _mod(BigInt.from(3) * point.$1 * point.$1 - BigInt.from(3), _p) *
        _mod(BigInt.two * point.$2, _p).modInverse(_p),
    _p,
  );
  return _apply(point, point.$1, slope);
}

(BigInt, BigInt) _apply((BigInt, BigInt) point, BigInt x2, BigInt slope) {
  final x = _mod(slope * slope - point.$1 - x2, _p);
  final y = _mod(slope * (point.$1 - x) - point.$2, _p);
  return (x, y);
}

BigInt _mod(BigInt value, BigInt modulus) {
  final result = value % modulus;
  return result.isNegative ? result + modulus : result;
}

(BigInt, BigInt)? _mul(BigInt x, BigInt y, BigInt scalar) {
  (BigInt, BigInt)? result;
  var point = (x, y);
  var rest = scalar;
  while (rest > BigInt.zero) {
    if (rest.isOdd) result = _add(result, point);
    point = _add(point, point)!;
    rest >>= 1;
  }
  return result;
}

BigInt _unsigned(List<int> bytes) {
  var value = BigInt.zero;
  for (final byte in bytes) {
    value = (value << 8) | BigInt.from(byte);
  }
  return value;
}

Uint8List _fixed(BigInt value, int width) {
  final out = Uint8List(width);
  var rest = value;
  for (var i = width - 1; i >= 0; i--) {
    out[i] = (rest & BigInt.from(0xff)).toInt();
    rest >>= 8;
  }
  return out;
}

Uint8List _random(int length) {
  final random = Random.secure();
  return Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256)),
  );
}
