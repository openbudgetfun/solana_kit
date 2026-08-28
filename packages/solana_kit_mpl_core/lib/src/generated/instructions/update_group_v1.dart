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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateGroupV1InstructionData {
  const UpdateGroupV1InstructionData({
    required this.newName,
    required this.newUri,
  }) : discriminator = 41;

  final int discriminator;
  final String? newName;
  final String? newUri;
}

Encoder<UpdateGroupV1InstructionData> getUpdateGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'newName',
      getNullableEncoder<String>(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
      ),
    ),
    (
      'newUri',
      getNullableEncoder<String>(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 41,
      'newName': value.newName,
      'newUri': value.newUri,
    },
  );
}

Decoder<UpdateGroupV1InstructionData> getUpdateGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'newName',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
    (
      'newUri',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateGroupV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(41),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateGroupV1InstructionData(
        newName: map['newName'] as String?,
        newUri: map['newUri'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateGroupV1InstructionData>(
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
      VariableSizeDecoder<UpdateGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateGroupV1InstructionData, UpdateGroupV1InstructionData>
getUpdateGroupV1InstructionDataCodec() {
  return combineCodec(
    getUpdateGroupV1InstructionDataEncoder(),
    getUpdateGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [UpdateGroupV1] instruction.
Instruction getUpdateGroupV1Instruction({
  required Address programAddress,
  required Address group,
  required Address payer,
  Address? authority,
  Address? newUpdateAuthority,
  required Address systemProgram,
  required String? newName,
  required String? newUri,
}) {
  final instructionData = UpdateGroupV1InstructionData(
    newName: newName,
    newUri: newUri,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (newUpdateAuthority != null)
        AccountMeta(address: newUpdateAuthority, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getUpdateGroupV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateGroupV1] instruction from raw instruction data.
UpdateGroupV1InstructionData parseUpdateGroupV1Instruction(
  Instruction instruction,
) {
  return getUpdateGroupV1InstructionDataDecoder().decode(instruction.data!);
}
