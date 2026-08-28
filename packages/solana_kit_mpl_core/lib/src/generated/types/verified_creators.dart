// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './verified_creators_signature.dart';

@immutable
class VerifiedCreators {
  const VerifiedCreators({
    required this.signatures,
  });

  final List<VerifiedCreatorsSignature> signatures;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifiedCreators &&
          runtimeType == other.runtimeType &&
          signatures == other.signatures;

  @override
  int get hashCode => signatures.hashCode;

  @override
  String toString() => 'VerifiedCreators(signatures: $signatures)';
}

Encoder<VerifiedCreators> getVerifiedCreatorsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'signatures',
      getArrayEncoder<VerifiedCreatorsSignature>(
        transformEncoder(
          getVerifiedCreatorsSignatureEncoder(),
          (VerifiedCreatorsSignature value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (VerifiedCreators value) => <String, Object?>{
      'signatures': value.signatures,
    },
  );
}

Decoder<VerifiedCreators> getVerifiedCreatorsDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('signatures', getArrayDecoder(getVerifiedCreatorsSignatureDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => VerifiedCreators(
      signatures: map['signatures']! as List<VerifiedCreatorsSignature>,
    ),
  );
}

Codec<VerifiedCreators, VerifiedCreators> getVerifiedCreatorsCodec() {
  return combineCodec(
    getVerifiedCreatorsEncoder(),
    getVerifiedCreatorsDecoder(),
  );
}
