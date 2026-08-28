// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ProgramConfigSetTreasuryInstructionData {
  ProgramConfigSetTreasuryInstructionData({
    required this.newTreasury,
  }) : discriminator = Uint8List.fromList([
         0x6f,
         0x2e,
         0xf3,
         0x75,
         0x90,
         0xbc,
         0xa2,
         0x6b,
       ]);

  final Uint8List discriminator;
  final Address newTreasury;
}

Encoder<ProgramConfigSetTreasuryInstructionData>
getProgramConfigSetTreasuryInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('newTreasury', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProgramConfigSetTreasuryInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x6f,
        0x2e,
        0xf3,
        0x75,
        0x90,
        0xbc,
        0xa2,
        0x6b,
      ]),
      'newTreasury': value.newTreasury,
    },
  );
}

Decoder<ProgramConfigSetTreasuryInstructionData>
getProgramConfigSetTreasuryInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('newTreasury', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'programConfigSetTreasury instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProgramConfigSetTreasuryInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x6f, 0x2e, 0xf3, 0x75, 0x90, 0xbc, 0xa2, 0x6b]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProgramConfigSetTreasuryInstructionData(
        newTreasury: map['newTreasury']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProgramConfigSetTreasuryInstructionData>(
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
      VariableSizeDecoder<ProgramConfigSetTreasuryInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ProgramConfigSetTreasuryInstructionData,
  ProgramConfigSetTreasuryInstructionData
>
getProgramConfigSetTreasuryInstructionDataCodec() {
  return combineCodec(
    getProgramConfigSetTreasuryInstructionDataEncoder(),
    getProgramConfigSetTreasuryInstructionDataDecoder(),
  );
}

/// Creates a [ProgramConfigSetTreasury] instruction.
Instruction getProgramConfigSetTreasuryInstruction({
  required Address programAddress,
  required Address programConfig,
  required Address authority,
  required Address newTreasury,
}) {
  final instructionData = ProgramConfigSetTreasuryInstructionData(
    newTreasury: newTreasury,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: programConfig, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getProgramConfigSetTreasuryInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ProgramConfigSetTreasury] instruction from raw instruction data.
ProgramConfigSetTreasuryInstructionData
parseProgramConfigSetTreasuryInstruction(Instruction instruction) {
  return getProgramConfigSetTreasuryInstructionDataDecoder().decode(
    instruction.data!,
  );
}
