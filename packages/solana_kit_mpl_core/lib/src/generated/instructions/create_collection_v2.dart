// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/external_plugin_adapter_init_info.dart';
import '../types/plugin_authority_pair.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateCollectionV2InstructionData {
  const CreateCollectionV2InstructionData({
    required this.name,
    required this.uri,
    required this.plugins,
    required this.externalPluginAdapters,
  }) : discriminator = 21;

  final int discriminator;
  final String name;
  final String uri;
  final List<PluginAuthorityPair>? plugins;
  final List<ExternalPluginAdapterInitInfo>? externalPluginAdapters;
}

Encoder<CreateCollectionV2InstructionData>
getCreateCollectionV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    (
      'plugins',
      getNullableEncoder<List<PluginAuthorityPair>>(
        getArrayEncoder<PluginAuthorityPair>(
          transformEncoder(
            getPluginAuthorityPairEncoder(),
            (PluginAuthorityPair value) => value,
          ),
        ),
      ),
    ),
    (
      'externalPluginAdapters',
      getNullableEncoder<List<ExternalPluginAdapterInitInfo>>(
        getArrayEncoder<ExternalPluginAdapterInitInfo>(
          transformEncoder(
            getExternalPluginAdapterInitInfoEncoder(),
            (ExternalPluginAdapterInitInfo value) => value,
          ),
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateCollectionV2InstructionData value) => <String, Object?>{
      'discriminator': 21,
      'name': value.name,
      'uri': value.uri,
      'plugins': value.plugins,
      'externalPluginAdapters': value.externalPluginAdapters,
    },
  );
}

Decoder<CreateCollectionV2InstructionData>
getCreateCollectionV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    (
      'plugins',
      getNullableDecoder<List<PluginAuthorityPair>>(
        getArrayDecoder(getPluginAuthorityPairDecoder()),
      ),
    ),
    (
      'externalPluginAdapters',
      getNullableDecoder<List<ExternalPluginAdapterInitInfo>>(
        getArrayDecoder(getExternalPluginAdapterInitInfoDecoder()),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createCollectionV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateCollectionV2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(21),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateCollectionV2InstructionData(
        name: map['name']! as String,
        uri: map['uri']! as String,
        plugins: map['plugins'] as List<PluginAuthorityPair>?,
        externalPluginAdapters:
            map['externalPluginAdapters']
                as List<ExternalPluginAdapterInitInfo>?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateCollectionV2InstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<CreateCollectionV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateCollectionV2InstructionData, CreateCollectionV2InstructionData>
getCreateCollectionV2InstructionDataCodec() {
  return combineCodec(
    getCreateCollectionV2InstructionDataEncoder(),
    getCreateCollectionV2InstructionDataDecoder(),
  );
}

/// Creates a [CreateCollectionV2] instruction.
Instruction getCreateCollectionV2Instruction({
  required Address programAddress,
  required Address collection,
  Address? updateAuthority,
  required Address payer,
  required Address systemProgram,
  required String name,
  required String uri,
  required List<PluginAuthorityPair>? plugins,
  required List<ExternalPluginAdapterInitInfo>? externalPluginAdapters,
}) {
  final instructionData = CreateCollectionV2InstructionData(
    name: name,
    uri: uri,
    plugins: plugins,
    externalPluginAdapters: externalPluginAdapters,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collection, role: AccountRole.writableSigner),
      if (updateAuthority != null)
        AccountMeta(address: updateAuthority, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateCollectionV2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateCollectionV2] instruction from raw instruction data.
CreateCollectionV2InstructionData parseCreateCollectionV2Instruction(
  Instruction instruction,
) {
  return getCreateCollectionV2InstructionDataDecoder().decode(
    instruction.data!,
  );
}
