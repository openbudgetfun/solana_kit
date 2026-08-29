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
import '../types/plugin_authority_pair.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateV1InstructionData {
  const CreateV1InstructionData({
    required this.dataState,
    required this.name,
    required this.uri,
    required this.plugins,
  }) : discriminator = 0;

  final int discriminator;
  final DataState dataState;
  final String name;
  final String uri;
  final List<PluginAuthorityPair>? plugins;
}

Encoder<CreateV1InstructionData> getCreateV1InstructionDataEncoder() {
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
  ]);

  return transformEncoder(
    structEncoder,
    (CreateV1InstructionData value) => <String, Object?>{
      'discriminator': 0,
      'dataState': value.dataState,
      'name': value.name,
      'uri': value.uri,
      'plugins': value.plugins,
    },
  );
}

Decoder<CreateV1InstructionData> getCreateV1InstructionDataDecoder() {
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
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateV1InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateV1InstructionData(
        dataState: map['dataState']! as DataState,
        name: map['name']! as String,
        uri: map['uri']! as String,
        plugins: map['plugins'] as List<PluginAuthorityPair>?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateV1InstructionData>(
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
      VariableSizeDecoder<CreateV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateV1InstructionData, CreateV1InstructionData>
getCreateV1InstructionDataCodec() {
  return combineCodec(
    getCreateV1InstructionDataEncoder(),
    getCreateV1InstructionDataDecoder(),
  );
}

/// Creates a [CreateV1] instruction.
Instruction getCreateV1Instruction({
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
}) {
  final instructionData = CreateV1InstructionData(
    dataState: dataState,
    name: name,
    uri: uri,
    plugins: plugins,
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
    data: getCreateV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateV1] instruction from raw instruction data.
CreateV1InstructionData parseCreateV1Instruction(Instruction instruction) {
  return getCreateV1InstructionDataDecoder().decode(instruction.data!);
}
