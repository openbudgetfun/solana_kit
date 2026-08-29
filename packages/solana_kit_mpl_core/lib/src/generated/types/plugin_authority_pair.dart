// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';

import './authority.dart';
import './plugin.dart';

@immutable
class PluginAuthorityPair {
  const PluginAuthorityPair({
    required this.plugin,
    required this.authority,
  });

  final Plugin plugin;
  final Authority? authority;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginAuthorityPair &&
          runtimeType == other.runtimeType &&
          plugin == other.plugin &&
          authority == other.authority;

  @override
  int get hashCode => Object.hash(plugin, authority);

  @override
  String toString() =>
      'PluginAuthorityPair(plugin: $plugin, authority: $authority)';
}

Encoder<PluginAuthorityPair> getPluginAuthorityPairEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('plugin', getPluginEncoder()),
    (
      'authority',
      getNullableEncoder<Authority>(
        transformEncoder(getAuthorityEncoder(), (Authority value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (PluginAuthorityPair value) => <String, Object?>{
      'plugin': value.plugin,
      'authority': value.authority,
    },
  );
}

Decoder<PluginAuthorityPair> getPluginAuthorityPairDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('plugin', getPluginDecoder()),
    ('authority', getNullableDecoder<Authority>(getAuthorityDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        PluginAuthorityPair(
          plugin: map['plugin']! as Plugin,
          authority: map['authority'] as Authority?,
        ),
  );
}

Codec<PluginAuthorityPair, PluginAuthorityPair> getPluginAuthorityPairCodec() {
  return combineCodec(
    getPluginAuthorityPairEncoder(),
    getPluginAuthorityPairDecoder(),
  );
}
