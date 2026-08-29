// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';

import '../types/key.dart';

@immutable
class PluginHeaderV1 {
  const PluginHeaderV1({
    required this.key,
    required this.pluginRegistryOffset,
  });

  final Key key;
  final BigInt pluginRegistryOffset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginHeaderV1 &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          pluginRegistryOffset == other.pluginRegistryOffset;

  @override
  int get hashCode => Object.hash(key, pluginRegistryOffset);

  @override
  String toString() =>
      'PluginHeaderV1(key: $key, pluginRegistryOffset: $pluginRegistryOffset)';
}

/// The size of the [PluginHeaderV1] account data in bytes.
const int pluginHeaderV1Size = 9;

Encoder<PluginHeaderV1> getPluginHeaderV1Encoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('key', getKeyEncoder()),
    ('pluginRegistryOffset', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PluginHeaderV1 value) => <String, Object?>{
      'key': value.key,
      'pluginRegistryOffset': value.pluginRegistryOffset,
    },
  );
}

Decoder<PluginHeaderV1> getPluginHeaderV1Decoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('key', getKeyDecoder()),
    ('pluginRegistryOffset', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'pluginHeaderV1 account decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PluginHeaderV1, int) readTopLevel(Uint8List bytes, int offset) {
    final (map, newOffset) = structDecoder.read(bytes, offset);

    return (
      PluginHeaderV1(
        key: map['key']! as Key,
        pluginRegistryOffset: map['pluginRegistryOffset']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PluginHeaderV1>(
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
      VariableSizeDecoder<PluginHeaderV1>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<PluginHeaderV1, PluginHeaderV1> getPluginHeaderV1Codec() {
  return combineCodec(getPluginHeaderV1Encoder(), getPluginHeaderV1Decoder());
}

Account<PluginHeaderV1> decodePluginHeaderV1(EncodedAccount encodedAccount) {
  return decodeAccount(encodedAccount, getPluginHeaderV1Decoder());
}
