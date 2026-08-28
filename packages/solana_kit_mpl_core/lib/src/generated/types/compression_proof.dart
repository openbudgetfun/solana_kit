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
          plugins == other.plugins;

  @override
  int get hashCode =>
      Object.hash(owner, updateAuthority, name, uri, seq, plugins);

  @override
  String toString() =>
      'CompressionProof(owner: $owner, updateAuthority: $updateAuthority, name: $name, uri: $uri, seq: $seq, plugins: $plugins)';
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
      getArrayEncoder<HashablePluginSchema>(
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
