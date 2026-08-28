// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import './authority.dart';
import './plugin_type.dart';

@immutable
class RegistryRecord {
  const RegistryRecord({
    required this.pluginType,
    required this.authority,
    required this.offset,
  });

  final PluginType pluginType;
  final Authority authority;
  final BigInt offset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistryRecord &&
          runtimeType == other.runtimeType &&
          pluginType == other.pluginType &&
          authority == other.authority &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(pluginType, authority, offset);

  @override
  String toString() =>
      'RegistryRecord(pluginType: $pluginType, authority: $authority, offset: $offset)';
}

Encoder<RegistryRecord> getRegistryRecordEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('pluginType', getPluginTypeEncoder()),
    ('authority', getAuthorityEncoder()),
    ('offset', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RegistryRecord value) => <String, Object?>{
      'pluginType': value.pluginType,
      'authority': value.authority,
      'offset': value.offset,
    },
  );
}

Decoder<RegistryRecord> getRegistryRecordDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('pluginType', getPluginTypeDecoder()),
    ('authority', getAuthorityDecoder()),
    ('offset', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => RegistryRecord(
      pluginType: map['pluginType']! as PluginType,
      authority: map['authority']! as Authority,
      offset: map['offset']! as BigInt,
    ),
  );
}

Codec<RegistryRecord, RegistryRecord> getRegistryRecordCodec() {
  return combineCodec(getRegistryRecordEncoder(), getRegistryRecordDecoder());
}
