// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/external_registry_record.dart';
import '../types/key.dart';
import '../types/registry_record.dart';

@immutable
class PluginRegistryV1 {
  const PluginRegistryV1({
    required this.key,
    required this.registry,
    required this.externalRegistry,
  });

  final Key key;
  final List<RegistryRecord> registry;
  final List<ExternalRegistryRecord> externalRegistry;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginRegistryV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          registry == other.registry &&
          externalRegistry == other.externalRegistry;

  @override
  int get hashCode => Object.hash(key, registry, externalRegistry);

  @override
  String toString() =>
      'PluginRegistryV1(key: $key, registry: $registry, externalRegistry: $externalRegistry)';
}

Encoder<PluginRegistryV1> getPluginRegistryV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    (
      'registry',
      getArrayEncoder(
        transformEncoder(
          getRegistryRecordEncoder(),
          (RegistryRecord value) => value,
        ),
      ),
    ),
    (
      'externalRegistry',
      getArrayEncoder(
        transformEncoder(
          getExternalRegistryRecordEncoder(),
          (ExternalRegistryRecord value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (PluginRegistryV1 value) => <String, Object?>{
      'key': value.key,
      'registry': value.registry,
      'externalRegistry': value.externalRegistry,
    },
  );
}

Decoder<PluginRegistryV1> getPluginRegistryV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('registry', getArrayDecoder(getRegistryRecordDecoder())),
    ('externalRegistry', getArrayDecoder(getExternalRegistryRecordDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'pluginRegistryV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PluginRegistryV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      PluginRegistryV1(
        key: map['key']! as Key,
        registry: map['registry']! as List<RegistryRecord>,
        externalRegistry:
            map['externalRegistry']! as List<ExternalRegistryRecord>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PluginRegistryV1>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength < structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<PluginRegistryV1>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<PluginRegistryV1, PluginRegistryV1> getPluginRegistryV1Codec() {
  return combineCodec(
    getPluginRegistryV1Encoder(),
    getPluginRegistryV1Decoder(),
  );
}

Account<PluginRegistryV1> decodePluginRegistryV1(
  EncodedAccount encodedAccount,
) {
  return decodeAccount(encodedAccount, getPluginRegistryV1Decoder());
}
