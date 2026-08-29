// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './payload_type.dart';

@immutable
class Payload {
  const Payload({
    required this.map,
  });

  final Map<String, PayloadType> map;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payload && runtimeType == other.runtimeType && map == other.map;

  @override
  int get hashCode => map.hashCode;

  @override
  String toString() => 'Payload(map: $map)';
}

Encoder<Payload> getPayloadEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'map',
      getMapEncoder(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
        getPayloadTypeEncoder(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Payload value) => <String, Object?>{
      'map': value.map,
    },
  );
}

Decoder<Payload> getPayloadDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    (
      'map',
      getMapDecoder(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
        getPayloadTypeDecoder(),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Payload(
      map: map['map']! as Map<String, PayloadType>,
    ),
  );
}

Codec<Payload, Payload> getPayloadCodec() {
  return combineCodec(getPayloadEncoder(), getPayloadDecoder());
}
