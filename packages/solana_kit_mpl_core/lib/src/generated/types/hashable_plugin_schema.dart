// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authority.dart';
import './plugin.dart';

@immutable
class HashablePluginSchema {
  const HashablePluginSchema({
    required this.index,
    required this.authority,
    required this.plugin,
  });

  final BigInt index;
  final Authority authority;
  final Plugin plugin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HashablePluginSchema &&
          runtimeType == other.runtimeType &&
          index == other.index &&
          authority == other.authority &&
          plugin == other.plugin;

  @override
  int get hashCode => Object.hash(index, authority, plugin);

  @override
  String toString() =>
      'HashablePluginSchema(index: $index, authority: $authority, plugin: $plugin)';
}

Encoder<HashablePluginSchema> getHashablePluginSchemaEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('index', getU64Encoder()),
    ('authority', getAuthorityEncoder()),
    ('plugin', getPluginEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (HashablePluginSchema value) => <String, Object?>{
      'index': value.index,
      'authority': value.authority,
      'plugin': value.plugin,
    },
  );
}

Decoder<HashablePluginSchema> getHashablePluginSchemaDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('index', getU64Decoder()),
    ('authority', getAuthorityDecoder()),
    ('plugin', getPluginDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        HashablePluginSchema(
          index: map['index']! as BigInt,
          authority: map['authority']! as Authority,
          plugin: map['plugin']! as Plugin,
        ),
  );
}

Codec<HashablePluginSchema, HashablePluginSchema>
getHashablePluginSchemaCodec() {
  return combineCodec(
    getHashablePluginSchemaEncoder(),
    getHashablePluginSchemaDecoder(),
  );
}
