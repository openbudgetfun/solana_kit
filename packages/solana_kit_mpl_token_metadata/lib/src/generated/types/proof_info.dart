// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

@immutable
class ProofInfo {
  const ProofInfo({
    required this.proof,
  });

  final List<Uint8List> proof;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProofInfo &&
          runtimeType == other.runtimeType &&
          _listEquals(proof, other.proof);

  @override
  int get hashCode => _listHashCode(proof);

  @override
  String toString() => 'ProofInfo(proof: $proof)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final left = a[i];
    final right = b[i];
    if (left is List<Object?> && right is List<Object?>) {
      if (!_listEquals(left, right)) return false;
    } else if (left != right) {
      return false;
    }
  }
  return true;
}

Object? _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  return value;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a.map(_deepHash));
}

Encoder<ProofInfo> getProofInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'proof',
      getArrayEncoder(
        transformEncoder(
          fixEncoderSize(getBytesEncoder(), 32, allowTruncation: false),
          (Uint8List value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ProofInfo value) => <String, Object?>{
      'proof': value.proof,
    },
  );
}

Decoder<ProofInfo> getProofInfoDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('proof', getArrayDecoder(fixDecoderSize(getBytesDecoder(), 32))),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => ProofInfo(
      proof: map['proof']! as List<Uint8List>,
    ),
  );
}

Codec<ProofInfo, ProofInfo> getProofInfoCodec() {
  return combineCodec(getProofInfoEncoder(), getProofInfoDecoder());
}
