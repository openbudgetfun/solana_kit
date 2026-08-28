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
class ProgramConfigSetAuthorityInstructionData {
  ProgramConfigSetAuthorityInstructionData({
    required this.newAuthority,
  }) : discriminator = Uint8List.fromList([
         0xee,
         0xf2,
         0x24,
         0xb5,
         0x20,
         0x8f,
         0xd8,
         0x4b,
       ]);

  final Uint8List discriminator;
  final Address newAuthority;
}

Encoder<ProgramConfigSetAuthorityInstructionData>
getProgramConfigSetAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('newAuthority', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ProgramConfigSetAuthorityInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xee,
        0xf2,
        0x24,
        0xb5,
        0x20,
        0x8f,
        0xd8,
        0x4b,
      ]),
      'newAuthority': value.newAuthority,
    },
  );
}

Decoder<ProgramConfigSetAuthorityInstructionData>
getProgramConfigSetAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('newAuthority', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'programConfigSetAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ProgramConfigSetAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xee, 0xf2, 0x24, 0xb5, 0x20, 0x8f, 0xd8, 0x4b]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ProgramConfigSetAuthorityInstructionData(
        newAuthority: map['newAuthority']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ProgramConfigSetAuthorityInstructionData>(
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
      VariableSizeDecoder<ProgramConfigSetAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ProgramConfigSetAuthorityInstructionData,
  ProgramConfigSetAuthorityInstructionData
>
getProgramConfigSetAuthorityInstructionDataCodec() {
  return combineCodec(
    getProgramConfigSetAuthorityInstructionDataEncoder(),
    getProgramConfigSetAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [ProgramConfigSetAuthority] instruction.
Instruction getProgramConfigSetAuthorityInstruction({
  required Address programAddress,
  required Address programConfig,
  required Address authority,
  required Address newAuthority,
}) {
  final instructionData = ProgramConfigSetAuthorityInstructionData(
    newAuthority: newAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: programConfig, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getProgramConfigSetAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ProgramConfigSetAuthority] instruction from raw instruction data.
ProgramConfigSetAuthorityInstructionData
parseProgramConfigSetAuthorityInstruction(Instruction instruction) {
  return getProgramConfigSetAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
