// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './attribute.dart';

@immutable
class Attributes {
  const Attributes({
    required this.attributeList,
  });

  final List<Attribute> attributeList;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Attributes &&
          runtimeType == other.runtimeType &&
          attributeList == other.attributeList;

  @override
  int get hashCode => attributeList.hashCode;

  @override
  String toString() => 'Attributes(attributeList: $attributeList)';
}

Encoder<Attributes> getAttributesEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'attributeList',
      getArrayEncoder<Attribute>(
        transformEncoder(getAttributeEncoder(), (Attribute value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (Attributes value) => <String, Object?>{
      'attributeList': value.attributeList,
    },
  );
}

Decoder<Attributes> getAttributesDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('attributeList', getArrayDecoder(getAttributeDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => Attributes(
      attributeList: map['attributeList']! as List<Attribute>,
    ),
  );
}

Codec<Attributes, Attributes> getAttributesCodec() {
  return combineCodec(getAttributesEncoder(), getAttributesDecoder());
}
