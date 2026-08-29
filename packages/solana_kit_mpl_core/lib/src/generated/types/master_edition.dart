// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

@immutable
class MasterEdition {
  const MasterEdition({
    required this.maxSupply,
    required this.name,
    required this.uri,
  });

  final int? maxSupply;
  final String? name;
  final String? uri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterEdition &&
          runtimeType == other.runtimeType &&
          maxSupply == other.maxSupply &&
          name == other.name &&
          uri == other.uri;

  @override
  int get hashCode => Object.hash(maxSupply, name, uri);

  @override
  String toString() =>
      'MasterEdition(maxSupply: $maxSupply, name: $name, uri: $uri)';
}

Encoder<MasterEdition> getMasterEditionEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'maxSupply',
      getNullableEncoder<int>(
        transformEncoder(getU32Encoder(), (int value) => value),
      ),
    ),
    (
      'name',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
    (
      'uri',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MasterEdition value) => <String, Object?>{
      'maxSupply': value.maxSupply,
      'name': value.name,
      'uri': value.uri,
    },
  );
}

Decoder<MasterEdition> getMasterEditionDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('maxSupply', getNullableDecoder<int>(getU32Decoder())),
    (
      'name',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
    (
      'uri',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => MasterEdition(
      maxSupply: map['maxSupply'] as int?,
      name: map['name'] as String?,
      uri: map['uri'] as String?,
    ),
  );
}

Codec<MasterEdition, MasterEdition> getMasterEditionCodec() {
  return combineCodec(getMasterEditionEncoder(), getMasterEditionDecoder());
}
