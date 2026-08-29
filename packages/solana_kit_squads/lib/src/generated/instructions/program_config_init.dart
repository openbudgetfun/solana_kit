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
class ProgramConfigInitInstructionData {
  ProgramConfigInitInstructionData({
    required this.authority,
    required this.multisigCreationFee,
    required this.treasury,
  }) : discriminator = Uint8List.fromList([
         0xb8,
         0xbc,
         0xc6,
         0xc3,
         0xcd,
         0x7c,
         0x75,
         0xd8,
       ]);

  final Uint8List discriminator;
  final Address authority;
  final BigInt multisigCreationFee;
  final Address treasury;
}

Encoder<ProgramConfigInitInstructionData>
getProgramConfigInitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('authority', getAddressEncoder()),
    ('multisigCreationFee', getU64Encoder()),
    ('treasury', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProgramConfigInitInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xb8,
        0xbc,
        0xc6,
        0xc3,
        0xcd,
        0x7c,
        0x75,
        0xd8,
      ]),
      'authority': value.authority,
      'multisigCreationFee': value.multisigCreationFee,
      'treasury': value.treasury,
    },
  );
}

Decoder<ProgramConfigInitInstructionData>
getProgramConfigInitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('authority', getAddressDecoder()),
    ('multisigCreationFee', getU64Decoder()),
    ('treasury', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'programConfigInit instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProgramConfigInitInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xb8, 0xbc, 0xc6, 0xc3, 0xcd, 0x7c, 0x75, 0xd8]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProgramConfigInitInstructionData(
        authority: map['authority']! as Address,
        multisigCreationFee: map['multisigCreationFee']! as BigInt,
        treasury: map['treasury']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProgramConfigInitInstructionData>(
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
      VariableSizeDecoder<ProgramConfigInitInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ProgramConfigInitInstructionData, ProgramConfigInitInstructionData>
getProgramConfigInitInstructionDataCodec() {
  return combineCodec(
    getProgramConfigInitInstructionDataEncoder(),
    getProgramConfigInitInstructionDataDecoder(),
  );
}

/// Creates a [ProgramConfigInit] instruction.
Instruction getProgramConfigInitInstruction({
  required Address programAddress,
  required Address programConfig,
  required Address initializer,
  required Address systemProgram,
  required Address authority,
  required BigInt multisigCreationFee,
  required Address treasury,
}) {
  final instructionData = ProgramConfigInitInstructionData(
    authority: authority,
    multisigCreationFee: multisigCreationFee,
    treasury: treasury,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: programConfig, role: AccountRole.writable),
      AccountMeta(address: initializer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getProgramConfigInitInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ProgramConfigInit] instruction from raw instruction data.
ProgramConfigInitInstructionData parseProgramConfigInitInstruction(
  Instruction instruction,
) {
  return getProgramConfigInitInstructionDataDecoder().decode(instruction.data!);
}
