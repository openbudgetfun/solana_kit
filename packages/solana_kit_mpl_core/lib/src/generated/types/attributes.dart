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
          _listEquals(attributeList, other.attributeList);

  @override
  int get hashCode => _listHashCode(attributeList);

  @override
  String toString() => 'Attributes(attributeList: $attributeList)';
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

Encoder<Attributes> getAttributesEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'attributeList',
      getArrayEncoder(
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
