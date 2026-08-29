// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './autograph_signature.dart';

@immutable
class Autograph {
  const Autograph({
    required this.signatures,
  });

  final List<AutographSignature> signatures;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Autograph &&
          runtimeType == other.runtimeType &&
          _listEquals(signatures, other.signatures);

  @override
  int get hashCode => _listHashCode(signatures);

  @override
  String toString() => 'Autograph(signatures: $signatures)';
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

Encoder<Autograph> getAutographEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'signatures',
      getArrayEncoder<AutographSignature>(
        transformEncoder(
          getAutographSignatureEncoder(),
          (AutographSignature value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Autograph value) => <String, Object?>{
      'signatures': value.signatures,
    },
  );
}

Decoder<Autograph> getAutographDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('signatures', getArrayDecoder(getAutographSignatureDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Autograph(
      signatures: map['signatures']! as List<AutographSignature>,
    ),
  );
}

Codec<Autograph, Autograph> getAutographCodec() {
  return combineCodec(getAutographEncoder(), getAutographDecoder());
}
