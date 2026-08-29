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
          _listEquals(signatures, other.signatures);

  @override
  int get hashCode => _listHashCode(signatures);

  @override
  String toString() => 'VerifiedCreators(signatures: $signatures)';
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null) return a == b;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHashCode<T>(List<T>? a) {
  if (a == null) return 0;
  return Object.hashAll(a);
}

Encoder<VerifiedCreators> getVerifiedCreatorsEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'signatures',
      getArrayEncoder(
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
