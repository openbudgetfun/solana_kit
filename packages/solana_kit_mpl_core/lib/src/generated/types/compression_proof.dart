// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

import './hashable_plugin_schema.dart';
import './update_authority.dart';

@immutable
class CompressionProof {
  const CompressionProof({
    required this.owner,
    required this.updateAuthority,
    required this.name,
    required this.uri,
    required this.seq,
    required this.plugins,
  });

  final Address owner;
  final UpdateAuthority updateAuthority;
  final String name;
  final String uri;
  final BigInt seq;
  final List<HashablePluginSchema> plugins;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompressionProof &&
          runtimeType == other.runtimeType &&
          owner == other.owner &&
          updateAuthority == other.updateAuthority &&
          name == other.name &&
          uri == other.uri &&
          seq == other.seq &&
          _listEquals(plugins, other.plugins);

  @override
  int get hashCode => Object.hash(
    owner,
    updateAuthority,
    name,
    uri,
    seq,
    _listHashCode(plugins),
  );

  @override
  String toString() =>
      'CompressionProof(owner: $owner, updateAuthority: $updateAuthority, name: $name, uri: $uri, seq: $seq, plugins: $plugins)';
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

Encoder<CompressionProof> getCompressionProofEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('owner', getAddressEncoder()),
    ('updateAuthority', getUpdateAuthorityEncoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('seq', getU64Encoder()),
    (
      'plugins',
      getArrayEncoder(
        transformEncoder(
          getHashablePluginSchemaEncoder(),
          (HashablePluginSchema value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CompressionProof value) => <String, Object?>{
      'owner': value.owner,
      'updateAuthority': value.updateAuthority,
      'name': value.name,
      'uri': value.uri,
      'seq': value.seq,
      'plugins': value.plugins,
    },
  );
}

Decoder<CompressionProof> getCompressionProofDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('owner', getAddressDecoder()),
    ('updateAuthority', getUpdateAuthorityDecoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('seq', getU64Decoder()),
    ('plugins', getArrayDecoder(getHashablePluginSchemaDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CompressionProof(
      owner: map['owner']! as Address,
      updateAuthority: map['updateAuthority']! as UpdateAuthority,
      name: map['name']! as String,
      uri: map['uri']! as String,
      seq: map['seq']! as BigInt,
      plugins: map['plugins']! as List<HashablePluginSchema>,
    ),
  );
}

Codec<CompressionProof, CompressionProof> getCompressionProofCodec() {
  return combineCodec(
    getCompressionProofEncoder(),
    getCompressionProofDecoder(),
  );
}
