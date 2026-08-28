// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

@immutable
class Attribute {
  const Attribute({
    required this.key,
    required this.value,
  });

  final String key;
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attribute &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => Object.hash(key, value);

  @override
  String toString() => 'Attribute(key: $key, value: $value)';
}

Encoder<Attribute> getAttributeEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('value', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (Attribute value) => <String, Object?>{
      'key': value.key,
      'value': value.value,
    },
  );
}

Decoder<Attribute> getAttributeDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('value', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Attribute(
      key: map['key']! as String,
      value: map['value']! as String,
    ),
  );
}

Codec<Attribute, Attribute> getAttributeCodec() {
  return combineCodec(getAttributeEncoder(), getAttributeDecoder());
}
