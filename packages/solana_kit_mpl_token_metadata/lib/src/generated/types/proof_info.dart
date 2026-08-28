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
          proof == other.proof;

  @override
  int get hashCode => proof.hashCode;

  @override
  String toString() => 'ProofInfo(proof: $proof)';
}

Encoder<ProofInfo> getProofInfoEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'proof',
      getArrayEncoder<Uint8List>(
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
