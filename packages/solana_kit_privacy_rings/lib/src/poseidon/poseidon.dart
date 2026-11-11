import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_privacy_rings/src/exception.dart';
import 'package:solana_kit_privacy_rings/src/poseidon/parameters.dart';

/// BN254 scalar field. Poseidon hashes live in this field.
///
/// This is `Fr`, not the base field used to compress curve points.
final BigInt bn254ScalarModulus = BigInt.parse(
  '21888242871839275222246405745257275088548364400416034343698204186575808495617',
);

/// Widest Poseidon arity `light-poseidon` accepts for the x5 parameters.
const maxPoseidonInputs = 12;

const _fullRounds = 8;
const _partialRounds = <int>[
  56,
  57,
  56,
  60,
  60,
  63,
  64,
  63,
  60,
  66,
  60,
  65,
  70,
  60,
  64,
];

class _Width {
  _Width(this.ark, this.mds);
  final List<BigInt> ark;
  final List<BigInt> mds;
}

final Map<int, _Width> _widths = _load();

Map<int, _Width> _load() {
  final bytes = base64.decode(poseidonParameterBase64.replaceAll('\n', ''));
  if (bytes.length < 6 ||
      bytes[0] != 0x50 ||
      bytes[1] != 0x53 ||
      bytes[2] != 0x44 ||
      bytes[3] != 0x4e) {
    // coverage:ignore-start
    throw PrivacyRingsException(
      'Poseidon parameters are not a PSDN table',
      code: 'invalid_parameters',
    );
    // coverage:ignore-end
  }
  final count = bytes[4];
  var offset = 5;
  final widths = <int, _Width>{};
  for (var i = 0; i < count; i++) {
    final width = bytes[offset];
    final arkCount = bytes[offset + 1] | (bytes[offset + 2] << 8);
    final mdsCount = bytes[offset + 3] | (bytes[offset + 4] << 8);
    offset += 5;
    final ark = _elements(bytes, offset, arkCount);
    offset += arkCount * 32;
    final mds = _elements(bytes, offset, mdsCount);
    offset += mdsCount * 32;
    widths[width] = _Width(ark, mds);
  }
  if (offset != bytes.length) {
    // coverage:ignore-start
    throw PrivacyRingsException(
      'Poseidon parameters have trailing bytes',
      code: 'invalid_parameters',
    );
    // coverage:ignore-end
  }
  return widths;
}

List<BigInt> _elements(Uint8List bytes, int offset, int count) {
  final values = <BigInt>[];
  for (var i = 0; i < count; i++) {
    var value = BigInt.zero;
    final start = offset + i * 32;
    for (var byte = 0; byte < 32; byte++) {
      value = (value << 8) | BigInt.from(bytes[start + byte]);
    }
    values.add(value);
  }
  return values;
}

/// Poseidon hash of one to twelve 32-byte big-endian field elements.
///
/// The permutation is `light-poseidon`'s circom x5 hash with a zero domain
/// tag, which is what `Poseidon::hashv` computes in
/// `program-libs/hasher/src/poseidon.rs`. Each input must be exactly 32
/// bytes and strictly below the scalar modulus. The result is 32 bytes,
/// big-endian.
Uint8List poseidonHash(List<Uint8List> inputs) {
  if (inputs.isEmpty || inputs.length > maxPoseidonInputs) {
    throw PrivacyRingsException(
      'Poseidon takes 1 to $maxPoseidonInputs inputs',
      code: 'invalid_length',
    );
  }
  final width = inputs.length + 1;
  final params = _widths[width];
  if (params == null) {
    // coverage:ignore-start
    throw PrivacyRingsException(
      'Poseidon has no parameters for ${inputs.length} inputs',
      code: 'invalid_parameters',
    );
    // coverage:ignore-end
  }
  final state = <BigInt>[BigInt.zero];
  for (final input in inputs) {
    if (input.length != 32) {
      throw PrivacyRingsException(
        'Poseidon input is ${input.length} bytes, the field takes 32',
        code: 'invalid_length',
      );
    }
    state.add(_field(input));
  }
  final partial = _partialRounds[width - 2];
  const half = _fullRounds ~/ 2;
  final rounds = _fullRounds + partial;
  for (var round = 0; round < half; round++) {
    _addRound(state, params.ark, round);
    for (var i = 0; i < width; i++) {
      state[i] = _sbox(state[i]);
    }
    _mix(state, params.mds);
  }
  for (var round = half; round < half + partial; round++) {
    _addRound(state, params.ark, round);
    state[0] = _sbox(state[0]);
    _mix(state, params.mds);
  }
  for (var round = half + partial; round < rounds; round++) {
    _addRound(state, params.ark, round);
    for (var i = 0; i < width; i++) {
      state[i] = _sbox(state[i]);
    }
    _mix(state, params.mds);
  }
  return _bytes(state[0]);
}

BigInt _field(Uint8List bytes) {
  var value = BigInt.zero;
  for (final byte in bytes) {
    value = (value << 8) | BigInt.from(byte);
  }
  if (value >= bn254ScalarModulus) {
    throw PrivacyRingsException(
      'Poseidon input is not below the scalar modulus',
      code: 'integer_range',
    );
  }
  return value;
}

void _addRound(List<BigInt> state, List<BigInt> ark, int round) {
  final width = state.length;
  for (var i = 0; i < width; i++) {
    state[i] = (state[i] + ark[round * width + i]) % bn254ScalarModulus;
  }
}

BigInt _sbox(BigInt value) {
  final square = (value * value) % bn254ScalarModulus;
  final fourth = (square * square) % bn254ScalarModulus;
  return (fourth * value) % bn254ScalarModulus;
}

void _mix(List<BigInt> state, List<BigInt> mds) {
  final width = state.length;
  final next = List<BigInt>.filled(width, BigInt.zero);
  for (var row = 0; row < width; row++) {
    var acc = BigInt.zero;
    for (var column = 0; column < width; column++) {
      acc =
          (acc + state[column] * mds[row * width + column]) %
          bn254ScalarModulus;
    }
    next[row] = acc;
  }
  for (var i = 0; i < width; i++) {
    state[i] = next[i];
  }
}

Uint8List _bytes(BigInt value) {
  final out = Uint8List(32);
  var rest = value;
  for (var i = 31; i >= 0; i--) {
    out[i] = (rest & BigInt.from(0xff)).toInt();
    rest >>= 8;
  }
  return out;
}

/// Right-aligns [bytes] in a 32-byte field element.
///
/// `right_align` in `spr_hasher`. A 31-byte secret becomes a field element
/// with a leading zero. [bytes] must be 1 to 32 bytes.
Uint8List rightAlign(List<int> bytes) {
  if (bytes.isEmpty || bytes.length > 32) {
    throw PrivacyRingsException(
      'a field element is 1 to 32 bytes',
      code: 'invalid_length',
    );
  }
  final field = Uint8List(32)..setRange(32 - bytes.length, 32, bytes);
  return field;
}

/// Big-endian u32 in a 32-byte field element.
Uint8List fieldU32(int value) {
  if (value < 0 || value > 0xffffffff) {
    throw PrivacyRingsException(
      'field u32 is outside 0..2^32-1',
      code: 'integer_range',
    );
  }
  final field = Uint8List(32);
  field[28] = (value >> 24) & 0xff;
  field[29] = (value >> 16) & 0xff;
  field[30] = (value >> 8) & 0xff;
  field[31] = value & 0xff;
  return field;
}

/// `0x` plus the unpadded lowercase hex of a 32-byte field.
///
/// `hex` in `sdk-libs/ts/src/client/prover/client.ts` uses
/// `toString(16)`, so a zero field is `0x0`.
String fieldHex(Uint8List bytes) {
  if (bytes.length != 32) {
    throw PrivacyRingsException(
      'field hex takes 32 bytes',
      code: 'invalid_length',
    );
  }
  var value = BigInt.zero;
  for (final byte in bytes) {
    value = (value << 8) | BigInt.from(byte);
  }
  return '0x${value.toRadixString(16)}';
}
