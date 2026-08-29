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
class UpdateCollectionExternalPluginAdapterV1InstructionData {
  const UpdateCollectionExternalPluginAdapterV1InstructionData({
    required this.key,
    required this.updateInfo,
  }) : discriminator = 27;

  final int discriminator;
  final ExternalPluginAdapterKey key;
  final ExternalPluginAdapterUpdateInfo updateInfo;
}

Encoder<UpdateCollectionExternalPluginAdapterV1InstructionData>
getUpdateCollectionExternalPluginAdapterV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('key', getExternalPluginAdapterKeyEncoder()),
    ('updateInfo', getExternalPluginAdapterUpdateInfoEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateCollectionExternalPluginAdapterV1InstructionData value) =>
        <String, Object?>{
          'discriminator': 27,
          'key': value.key,
          'updateInfo': value.updateInfo,
        },
  );
}

Decoder<UpdateCollectionExternalPluginAdapterV1InstructionData>
getUpdateCollectionExternalPluginAdapterV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('key', getExternalPluginAdapterKeyDecoder()),
    ('updateInfo', getExternalPluginAdapterUpdateInfoDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'updateCollectionExternalPluginAdapterV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateCollectionExternalPluginAdapterV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateCollectionExternalPluginAdapterV1InstructionData(
        key: map['key']! as ExternalPluginAdapterKey,
        updateInfo: map['updateInfo']! as ExternalPluginAdapterUpdateInfo,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateCollectionExternalPluginAdapterV1InstructionData>(
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
      VariableSizeDecoder<
        UpdateCollectionExternalPluginAdapterV1InstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateCollectionExternalPluginAdapterV1InstructionData,
  UpdateCollectionExternalPluginAdapterV1InstructionData
>
getUpdateCollectionExternalPluginAdapterV1InstructionDataCodec() {
  return combineCodec(
    getUpdateCollectionExternalPluginAdapterV1InstructionDataEncoder(),
    getUpdateCollectionExternalPluginAdapterV1InstructionDataDecoder(),
  );
}

/// Creates a [UpdateCollectionExternalPluginAdapterV1] instruction.
Instruction getUpdateCollectionExternalPluginAdapterV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterKey key,
  required ExternalPluginAdapterUpdateInfo updateInfo,
}) {
  final instructionData =
      UpdateCollectionExternalPluginAdapterV1InstructionData(
        key: key,
        updateInfo: updateInfo,
      );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collection, role: AccountRole.writable),
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
    data: getUpdateCollectionExternalPluginAdapterV1InstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [UpdateCollectionExternalPluginAdapterV1] instruction from raw instruction data.
UpdateCollectionExternalPluginAdapterV1InstructionData
parseUpdateCollectionExternalPluginAdapterV1Instruction(
  Instruction instruction,
) {
  return getUpdateCollectionExternalPluginAdapterV1InstructionDataDecoder()
      .decode(instruction.data!);
}
