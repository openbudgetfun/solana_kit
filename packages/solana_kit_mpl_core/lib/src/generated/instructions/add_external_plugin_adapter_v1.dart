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

import '../types/external_plugin_adapter_init_info.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AddExternalPluginAdapterV1InstructionData {
  const AddExternalPluginAdapterV1InstructionData({
    required this.initInfo,
  }) : discriminator = 22;

  final int discriminator;
  final ExternalPluginAdapterInitInfo initInfo;
}

Encoder<AddExternalPluginAdapterV1InstructionData>
getAddExternalPluginAdapterV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('initInfo', getExternalPluginAdapterInitInfoEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AddExternalPluginAdapterV1InstructionData value) => <String, Object?>{
      'discriminator': 22,
      'initInfo': value.initInfo,
    },
  );
}

Decoder<AddExternalPluginAdapterV1InstructionData>
getAddExternalPluginAdapterV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('initInfo', getExternalPluginAdapterInitInfoDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'addExternalPluginAdapterV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AddExternalPluginAdapterV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(22),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AddExternalPluginAdapterV1InstructionData(
        initInfo: map['initInfo']! as ExternalPluginAdapterInitInfo,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AddExternalPluginAdapterV1InstructionData>(
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
      VariableSizeDecoder<AddExternalPluginAdapterV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  AddExternalPluginAdapterV1InstructionData,
  AddExternalPluginAdapterV1InstructionData
>
getAddExternalPluginAdapterV1InstructionDataCodec() {
  return combineCodec(
    getAddExternalPluginAdapterV1InstructionDataEncoder(),
    getAddExternalPluginAdapterV1InstructionDataDecoder(),
  );
}

/// Creates a [AddExternalPluginAdapterV1] instruction.
Instruction getAddExternalPluginAdapterV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterInitInfo initInfo,
}) {
  final instructionData = AddExternalPluginAdapterV1InstructionData(
    initInfo: initInfo,
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
    data: getAddExternalPluginAdapterV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [AddExternalPluginAdapterV1] instruction from raw instruction data.
AddExternalPluginAdapterV1InstructionData
parseAddExternalPluginAdapterV1Instruction(Instruction instruction) {
  return getAddExternalPluginAdapterV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
