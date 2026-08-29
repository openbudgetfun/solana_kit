// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './relationship_kind.dart';

@immutable
class RelationshipEntry {
  const RelationshipEntry({
    required this.kind,
    required this.key,
  });

  final RelationshipKind kind;
  final Address key;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RelationshipEntry &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          key == other.key;

  @override
  int get hashCode => Object.hash(kind, key);

  @override
  String toString() => 'RelationshipEntry(kind: $kind, key: $key)';
}

Encoder<RelationshipEntry> getRelationshipEntryEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('kind', getRelationshipKindEncoder()),
    ('key', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RelationshipEntry value) => <String, Object?>{
      'kind': value.kind,
      'key': value.key,
    },
  );
}

Decoder<RelationshipEntry> getRelationshipEntryDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('kind', getRelationshipKindDecoder()),
    ('key', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RelationshipEntry(
          kind: map['kind']! as RelationshipKind,
          key: map['key']! as Address,
        ),
  );
}

Codec<RelationshipEntry, RelationshipEntry> getRelationshipEntryCodec() {
  return combineCodec(
    getRelationshipEntryEncoder(),
    getRelationshipEntryDecoder(),
  );
}
