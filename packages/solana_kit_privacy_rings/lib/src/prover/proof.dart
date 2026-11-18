import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/codec/transact.dart';
import 'package:solana_kit_privacy_rings/src/constants.dart';
import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/prover/proving_keys.dart';

/// Parses a gnark proof JSON value into the compressed [TransactProof] a
/// `transact` instruction carries.
///
/// The conversion matches `parseCheckedProof` and `compressProof` in
/// `sdk-libs/ts/src/client/prover/proof.ts`, including the negation of
/// `ar`'s y coordinate before G1 compression. G2 is stored uncompressed.
/// This function checks that every G2 coordinate is a canonical field
/// element. It does not test G2 twist-subgroup membership; the on-chain
/// verifier does that. G1 points are checked against `y^2 = x^3 + 3`.
///
/// [circuit] selects the proving-key pin. The response must report that
/// pin in `provingKeySha256`. A missing or different pin is rejected.
///
/// BSB22 `proofCommitment` fields are checked when present and are not
/// copied onto [TransactProof], which is what
/// `CompressedProof.toTransactProof` does.
TransactProof parseProverProof(Object? value, {required String circuit}) {
  final expected = provingKeySha256(circuit);
  if (expected == null) {
    throw PrivacyRingsException(
      'no proving-key pin is known for $circuit',
      code: 'unknown_circuit',
    );
  }
  final proofValue = value is Map && value.containsKey('proof')
      ? value['proof']
      : value;
  if (proofValue != null) {
    _checkProvingKey(proofValue, expected, circuit);
  }
  final parsed = _parseProof(proofValue);
  return _compress(parsed);
}

void _checkProvingKey(Object? proofValue, String expected, String circuit) {
  if (proofValue is! Map || !proofValue.containsKey('provingKeySha256')) {
    throw PrivacyRingsException(
      'prover response for $circuit omitted provingKeySha256',
      code: 'proving_key_missing',
    );
  }
  final reported = proofValue['provingKeySha256'];
  if (reported is! String || !RegExp(r'^[0-9a-f]{64}$').hasMatch(reported)) {
    throw PrivacyRingsException(
      'provingKeySha256 is not 64 lowercase hex characters',
      code: 'invalid_response',
    );
  }
  if (reported != expected) {
    throw PrivacyRingsException(
      'prover used a different key for $circuit',
      code: 'proving_key_mismatch',
    );
  }
}

class _G1 {
  _G1(this.x, this.y);
  final BigInt x;
  final BigInt y;
}

class _Parsed {
  _Parsed(this.a, this.b, this.c);
  final _G1 a;
  final Uint8List b;
  final _G1 c;
}

_Parsed _parseProof(Object? value) {
  if (value == null) {
    throw PrivacyRingsException(
      'prover returned a null proof',
      code: 'prover_server',
    );
  }
  final proof = _map(value, r'$.proof');
  final a = _parseG1(proof['ar'], r'$.proof.ar');
  final negatedY = a.y == BigInt.zero ? BigInt.zero : bn254BaseModulus - a.y;
  final b = _parseG2(proof['bs'], r'$.proof.bs');
  final c = _parseG1(proof['krs'], r'$.proof.krs');
  final commitment = _present(proof['proofCommitment']);
  final pok = _present(proof['proofCommitmentPok']);
  if (commitment || pok) {
    _parseG1(proof['proofCommitment'], r'$.proof.proofCommitment');
    _parseG1(proof['proofCommitmentPok'], r'$.proof.proofCommitmentPok');
  }
  return _Parsed(_G1(a.x, negatedY), b, c);
}

bool _present(Object? value) =>
    value != null && !(value is List && value.isEmpty);

TransactProof _compress(_Parsed proof) {
  return TransactProof(
    a: _compressG1(proof.a, 'proof.a'),
    b: proof.b,
    c: _compressG1(proof.c, 'proof.c'),
  );
}

Uint8List _compressG1(_G1 point, String name) {
  if (point.x == BigInt.zero && point.y == BigInt.zero) return Uint8List(32);
  _validateG1(point.x, point.y, name);
  final bytes = _be32(point.x);
  if (point.y > (bn254BaseModulus - BigInt.one) >> 1) {
    bytes[0] |= 0x80;
  }
  return bytes;
}

void _validateG1(BigInt x, BigInt y, String name) {
  final p = bn254BaseModulus;
  if (x >= p ||
      y >= p ||
      _mod(y * y - _mod(x * x) * x - BigInt.from(3)) != BigInt.zero) {
    throw PrivacyRingsException(
      '$name is not a BN254 G1 point',
      code: 'proof_point',
    );
  }
}

_G1 _parseG1(Object? value, String path) {
  final coordinates = _list(value, path);
  if (coordinates.length != 2) _invalid(path);
  final x = _coordinate(coordinates[0], '$path[0]');
  final y = _coordinate(coordinates[1], '$path[1]');
  if (x != BigInt.zero || y != BigInt.zero) _validateG1(x, y, path);
  return _G1(x, y);
}

Uint8List _parseG2(Object? value, String path) {
  final rows = _list(value, path);
  if (rows.length != 2) _invalid(path);
  final coordinates = <BigInt>[];
  for (final (rowIndex, row) in rows.indexed) {
    final values = _list(row, '$path[$rowIndex]');
    if (values.length != 2) _invalid('$path[$rowIndex]');
    for (final (index, item) in values.indexed) {
      coordinates.add(_coordinate(item, '$path[$rowIndex][$index]'));
    }
  }
  final bytes = Uint8List(128);
  for (final (index, coordinate) in coordinates.indexed) {
    bytes.setRange(index * 32, index * 32 + 32, _be32(coordinate));
  }
  return bytes;
}

BigInt _coordinate(Object? value, String path) {
  if (value is! String) _invalid(path);
  final digits = value.startsWith('0x') || value.startsWith('0X')
      ? value.substring(2)
      : value;
  if (digits.isEmpty || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(digits)) {
    _invalid(path);
  }
  final parsed = BigInt.parse(digits, radix: 16);
  if (parsed >= bn254BaseModulus) _invalid(path);
  return parsed;
}

Uint8List _be32(BigInt value) {
  final bytes = Uint8List(32);
  var rest = value;
  for (var i = 31; i >= 0; i--) {
    bytes[i] = (rest & BigInt.from(0xff)).toInt();
    rest >>= 8;
  }
  return bytes;
}

BigInt _mod(BigInt value) {
  final remainder = value % bn254BaseModulus;
  return remainder.isNegative ? remainder + bn254BaseModulus : remainder;
}

Map<Object?, Object?> _map(Object? value, String path) {
  if (value is! Map) _invalid(path);
  return value;
}

List<Object?> _list(Object? value, String path) {
  if (value is! List) _invalid(path);
  return value;
}

Never _invalid(String path) {
  throw PrivacyRingsException(
    'proof field $path is malformed',
    code: 'proof_parse',
  );
}
