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
class AddCollectionExternalPluginAdapterV1InstructionData {
  const AddCollectionExternalPluginAdapterV1InstructionData({
    required this.initInfo,
  }) : discriminator = 23;

  final int discriminator;
  final ExternalPluginAdapterInitInfo initInfo;
}

Encoder<AddCollectionExternalPluginAdapterV1InstructionData>
getAddCollectionExternalPluginAdapterV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('initInfo', getExternalPluginAdapterInitInfoEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (AddCollectionExternalPluginAdapterV1InstructionData value) =>
        <String, Object?>{
          'discriminator': 23,
          'initInfo': value.initInfo,
        },
  );
}

Decoder<AddCollectionExternalPluginAdapterV1InstructionData>
getAddCollectionExternalPluginAdapterV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('initInfo', getExternalPluginAdapterInitInfoDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'addCollectionExternalPluginAdapterV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AddCollectionExternalPluginAdapterV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(23),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AddCollectionExternalPluginAdapterV1InstructionData(
        initInfo: map['initInfo']! as ExternalPluginAdapterInitInfo,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AddCollectionExternalPluginAdapterV1InstructionData>(
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
      VariableSizeDecoder<AddCollectionExternalPluginAdapterV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  AddCollectionExternalPluginAdapterV1InstructionData,
  AddCollectionExternalPluginAdapterV1InstructionData
>
getAddCollectionExternalPluginAdapterV1InstructionDataCodec() {
  return combineCodec(
    getAddCollectionExternalPluginAdapterV1InstructionDataEncoder(),
    getAddCollectionExternalPluginAdapterV1InstructionDataDecoder(),
  );
}

/// Creates a [AddCollectionExternalPluginAdapterV1] instruction.
Instruction getAddCollectionExternalPluginAdapterV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required ExternalPluginAdapterInitInfo initInfo,
}) {
  final instructionData = AddCollectionExternalPluginAdapterV1InstructionData(
    initInfo: initInfo,
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
    data: getAddCollectionExternalPluginAdapterV1InstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [AddCollectionExternalPluginAdapterV1] instruction from raw instruction data.
AddCollectionExternalPluginAdapterV1InstructionData
parseAddCollectionExternalPluginAdapterV1Instruction(Instruction instruction) {
  return getAddCollectionExternalPluginAdapterV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
