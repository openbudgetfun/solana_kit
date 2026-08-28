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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ProgramConfigSetMultisigCreationFeeInstructionData {
  ProgramConfigSetMultisigCreationFeeInstructionData({
    required this.newMultisigCreationFee,
  }) : discriminator = Uint8List.fromList([
         0x65,
         0xa0,
         0xf9,
         0x3f,
         0x9a,
         0xd7,
         0x99,
         0x0d,
       ]);

  final Uint8List discriminator;
  final BigInt newMultisigCreationFee;
}

Encoder<ProgramConfigSetMultisigCreationFeeInstructionData>
getProgramConfigSetMultisigCreationFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('newMultisigCreationFee', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProgramConfigSetMultisigCreationFeeInstructionData value) =>
        <String, Object?>{
          'discriminator': Uint8List.fromList([
            0x65,
            0xa0,
            0xf9,
            0x3f,
            0x9a,
            0xd7,
            0x99,
            0x0d,
          ]),
          'newMultisigCreationFee': value.newMultisigCreationFee,
        },
  );
}

Decoder<ProgramConfigSetMultisigCreationFeeInstructionData>
getProgramConfigSetMultisigCreationFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('newMultisigCreationFee', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'programConfigSetMultisigCreationFee instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProgramConfigSetMultisigCreationFeeInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x65, 0xa0, 0xf9, 0x3f, 0x9a, 0xd7, 0x99, 0x0d]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProgramConfigSetMultisigCreationFeeInstructionData(
        newMultisigCreationFee: map['newMultisigCreationFee']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProgramConfigSetMultisigCreationFeeInstructionData>(
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
      VariableSizeDecoder<ProgramConfigSetMultisigCreationFeeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ProgramConfigSetMultisigCreationFeeInstructionData,
  ProgramConfigSetMultisigCreationFeeInstructionData
>
getProgramConfigSetMultisigCreationFeeInstructionDataCodec() {
  return combineCodec(
    getProgramConfigSetMultisigCreationFeeInstructionDataEncoder(),
    getProgramConfigSetMultisigCreationFeeInstructionDataDecoder(),
  );
}

/// Creates a [ProgramConfigSetMultisigCreationFee] instruction.
Instruction getProgramConfigSetMultisigCreationFeeInstruction({
  required Address programAddress,
  required Address programConfig,
  required Address authority,
  required BigInt newMultisigCreationFee,
}) {
  final instructionData = ProgramConfigSetMultisigCreationFeeInstructionData(
    newMultisigCreationFee: newMultisigCreationFee,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: programConfig, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getProgramConfigSetMultisigCreationFeeInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ProgramConfigSetMultisigCreationFee] instruction from raw instruction data.
ProgramConfigSetMultisigCreationFeeInstructionData
parseProgramConfigSetMultisigCreationFeeInstruction(Instruction instruction) {
  return getProgramConfigSetMultisigCreationFeeInstructionDataDecoder().decode(
    instruction.data!,
  );
}
