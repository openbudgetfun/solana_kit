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

import '../types/plugin.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdatePluginV1InstructionData {
  const UpdatePluginV1InstructionData({
    required this.plugin,
  }) : discriminator = 6;

  final int discriminator;
  final Plugin plugin;
}

Encoder<UpdatePluginV1InstructionData>
getUpdatePluginV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('plugin', getPluginEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdatePluginV1InstructionData value) => <String, Object?>{
      'discriminator': 6,
      'plugin': value.plugin,
    },
  );
}

Decoder<UpdatePluginV1InstructionData>
getUpdatePluginV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('plugin', getPluginDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updatePluginV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdatePluginV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(6),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdatePluginV1InstructionData(
        plugin: map['plugin']! as Plugin,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdatePluginV1InstructionData>(
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
      VariableSizeDecoder<UpdatePluginV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdatePluginV1InstructionData, UpdatePluginV1InstructionData>
getUpdatePluginV1InstructionDataCodec() {
  return combineCodec(
    getUpdatePluginV1InstructionDataEncoder(),
    getUpdatePluginV1InstructionDataDecoder(),
  );
}

/// Creates a [UpdatePluginV1] instruction.
Instruction getUpdatePluginV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required Plugin plugin,
}) {
  final instructionData = UpdatePluginV1InstructionData(
    plugin: plugin,
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
    data: getUpdatePluginV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdatePluginV1] instruction from raw instruction data.
UpdatePluginV1InstructionData parseUpdatePluginV1Instruction(
  Instruction instruction,
) {
  return getUpdatePluginV1InstructionDataDecoder().decode(instruction.data!);
}
