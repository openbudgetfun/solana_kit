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
class UpdateTokenGroupUpdateAuthorityInstructionData {
  UpdateTokenGroupUpdateAuthorityInstructionData({
    required this.newUpdateAuthority,
  }) : discriminator = Uint8List.fromList([
         0xa1,
         0x69,
         0x58,
         0x01,
         0xed,
         0xdd,
         0xd8,
         0xcb,
       ]);

  final Uint8List discriminator;
  final Address? newUpdateAuthority;
}

Encoder<UpdateTokenGroupUpdateAuthorityInstructionData>
getUpdateTokenGroupUpdateAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    (
      'newUpdateAuthority',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTokenGroupUpdateAuthorityInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xa1,
        0x69,
        0x58,
        0x01,
        0xed,
        0xdd,
        0xd8,
        0xcb,
      ]),
      'newUpdateAuthority': value.newUpdateAuthority,
    },
  );
}

Decoder<UpdateTokenGroupUpdateAuthorityInstructionData>
getUpdateTokenGroupUpdateAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    (
      'newUpdateAuthority',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'updateTokenGroupUpdateAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateTokenGroupUpdateAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xa1, 0x69, 0x58, 0x01, 0xed, 0xdd, 0xd8, 0xcb]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateTokenGroupUpdateAuthorityInstructionData(
        newUpdateAuthority: map['newUpdateAuthority'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateTokenGroupUpdateAuthorityInstructionData>(
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
      VariableSizeDecoder<UpdateTokenGroupUpdateAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateTokenGroupUpdateAuthorityInstructionData,
  UpdateTokenGroupUpdateAuthorityInstructionData
>
getUpdateTokenGroupUpdateAuthorityInstructionDataCodec() {
  return combineCodec(
    getUpdateTokenGroupUpdateAuthorityInstructionDataEncoder(),
    getUpdateTokenGroupUpdateAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [UpdateTokenGroupUpdateAuthority] instruction.
Instruction getUpdateTokenGroupUpdateAuthorityInstruction({
  required Address programAddress,
  required Address group,
  required Address updateAuthority,
  required Address? newUpdateAuthority,
}) {
  final instructionData = UpdateTokenGroupUpdateAuthorityInstructionData(
    newUpdateAuthority: newUpdateAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateTokenGroupUpdateAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateTokenGroupUpdateAuthority] instruction from raw instruction data.
UpdateTokenGroupUpdateAuthorityInstructionData
parseUpdateTokenGroupUpdateAuthorityInstruction(Instruction instruction) {
  return getUpdateTokenGroupUpdateAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
