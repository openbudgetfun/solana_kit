// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/external_plugin_adapter_key.dart';
import '../types/external_plugin_adapter_update_info.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateExternalPluginAdapterV1InstructionData {
  const UpdateExternalPluginAdapterV1InstructionData({
    required this.key,
    required this.updateInfo,
  }) : discriminator = 26;

  final int discriminator;
  final ExternalPluginAdapterKey key;
  final ExternalPluginAdapterUpdateInfo updateInfo;
}

Encoder<UpdateExternalPluginAdapterV1InstructionData>
getUpdateExternalPluginAdapterV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('key', getExternalPluginAdapterKeyEncoder()),
    ('updateInfo', getExternalPluginAdapterUpdateInfoEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateExternalPluginAdapterV1InstructionData value) => <String, Object?>{
      'discriminator': 26,
      'key': value.key,
      'updateInfo': value.updateInfo,
    },
  );
}

Decoder<UpdateExternalPluginAdapterV1InstructionData>
getUpdateExternalPluginAdapterV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('key', getExternalPluginAdapterKeyDecoder()),
    ('updateInfo', getExternalPluginAdapterUpdateInfoDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateExternalPluginAdapterV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateExternalPluginAdapterV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(26),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateExternalPluginAdapterV1InstructionData(
        key: map['key']! as ExternalPluginAdapterKey,
        updateInfo: map['updateInfo']! as ExternalPluginAdapterUpdateInfo,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateExternalPluginAdapterV1InstructionData>(
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
      VariableSizeDecoder<UpdateExternalPluginAdapterV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateExternalPluginAdapterV1InstructionData,
  UpdateExternalPluginAdapterV1InstructionData
>
getUpdateExternalPluginAdapterV1InstructionDataCodec() {
  return combineCodec(
    getUpdateExternalPluginAdapterV1InstructionDataEncoder(),
    getUpdateExternalPluginAdapterV1InstructionDataDecoder(),
  );
}

/// Creates a [UpdateExternalPluginAdapterV1] instruction.
Instruction getUpdateExternalPluginAdapterV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterKey key,
  required ExternalPluginAdapterUpdateInfo updateInfo,
}) {
  final instructionData = UpdateExternalPluginAdapterV1InstructionData(
    key: key,
    updateInfo: updateInfo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: asset, role: AccountRole.writable),
      if (collection != null)
        AccountMeta(address: collection, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getUpdateExternalPluginAdapterV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateExternalPluginAdapterV1] instruction from raw instruction data.
UpdateExternalPluginAdapterV1InstructionData
parseUpdateExternalPluginAdapterV1Instruction(Instruction instruction) {
  return getUpdateExternalPluginAdapterV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
