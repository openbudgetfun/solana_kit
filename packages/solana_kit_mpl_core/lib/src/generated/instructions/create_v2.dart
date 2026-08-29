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

import '../types/data_state.dart';
import '../types/external_plugin_adapter_init_info.dart';
import '../types/plugin_authority_pair.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateV2InstructionData {
  const CreateV2InstructionData({
    required this.dataState,
    required this.name,
    required this.uri,
    required this.plugins,
    required this.externalPluginAdapters,
  }) : discriminator = 20;

  final int discriminator;
  final DataState dataState;
  final String name;
  final String uri;
  final List<PluginAuthorityPair>? plugins;
  final List<ExternalPluginAdapterInitInfo>? externalPluginAdapters;
}

Encoder<CreateV2InstructionData> getCreateV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('dataState', getDataStateEncoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    (
      'plugins',
      getNullableEncoder<List<PluginAuthorityPair>>(
        transformEncoder(
          getArrayEncoder(
            transformEncoder(
              getPluginAuthorityPairEncoder(),
              (PluginAuthorityPair value) => value,
            ),
          ),
          (List<PluginAuthorityPair> value) => value,
        ),
      ),
    ),
    (
      'externalPluginAdapters',
      getNullableEncoder<List<ExternalPluginAdapterInitInfo>>(
        transformEncoder(
          getArrayEncoder(
            transformEncoder(
              getExternalPluginAdapterInitInfoEncoder(),
              (ExternalPluginAdapterInitInfo value) => value,
            ),
          ),
          (List<ExternalPluginAdapterInitInfo> value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateV2InstructionData value) => <String, Object?>{
      'discriminator': 20,
      'dataState': value.dataState,
      'name': value.name,
      'uri': value.uri,
      'plugins': value.plugins,
      'externalPluginAdapters': value.externalPluginAdapters,
    },
  );
}

Decoder<CreateV2InstructionData> getCreateV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('dataState', getDataStateDecoder()),
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
        'codecDescription': 'createV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateV2InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(20),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateV2InstructionData(
        dataState: map['dataState']! as DataState,
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
      FixedSizeDecoder<CreateV2InstructionData>(
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
      VariableSizeDecoder<CreateV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateV2InstructionData, CreateV2InstructionData>
getCreateV2InstructionDataCodec() {
  return combineCodec(
    getCreateV2InstructionDataEncoder(),
    getCreateV2InstructionDataDecoder(),
  );
}

/// Creates a [CreateV2] instruction.
Instruction getCreateV2Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  Address? authority,
  required Address payer,
  Address? owner,
  Address? updateAuthority,
  required Address systemProgram,
  Address? logWrapper,
  required DataState dataState,
  required String name,
  required String uri,
  required List<PluginAuthorityPair>? plugins,
  required List<ExternalPluginAdapterInitInfo>? externalPluginAdapters,
}) {
  final instructionData = CreateV2InstructionData(
    dataState: dataState,
    name: name,
    uri: uri,
    plugins: plugins,
    externalPluginAdapters: externalPluginAdapters,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: asset, role: AccountRole.writableSigner),
      if (collection != null)
        AccountMeta(address: collection, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (owner != null)
        AccountMeta(address: owner, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (updateAuthority != null)
        AccountMeta(address: updateAuthority, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getCreateV2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateV2] instruction from raw instruction data.
CreateV2InstructionData parseCreateV2Instruction(Instruction instruction) {
  return getCreateV2InstructionDataDecoder().decode(instruction.data!);
}
