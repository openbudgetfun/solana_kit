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
class UpdateTokenMetadataUpdateAuthorityInstructionData {
  UpdateTokenMetadataUpdateAuthorityInstructionData({
    required this.newUpdateAuthority,
  }) : discriminator = Uint8List.fromList([
         0xd7,
         0xe4,
         0xa6,
         0xe4,
         0x54,
         0x64,
         0x56,
         0x7b,
       ]);

  final Uint8List discriminator;
  final Address? newUpdateAuthority;
}

Encoder<UpdateTokenMetadataUpdateAuthorityInstructionData>
getUpdateTokenMetadataUpdateAuthorityInstructionDataEncoder() {
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
    (UpdateTokenMetadataUpdateAuthorityInstructionData value) =>
        <String, Object?>{
          'discriminator': Uint8List.fromList([
            0xd7,
            0xe4,
            0xa6,
            0xe4,
            0x54,
            0x64,
            0x56,
            0x7b,
          ]),
          'newUpdateAuthority': value.newUpdateAuthority,
        },
  );
}

Decoder<UpdateTokenMetadataUpdateAuthorityInstructionData>
getUpdateTokenMetadataUpdateAuthorityInstructionDataDecoder() {
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
            'updateTokenMetadataUpdateAuthority instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateTokenMetadataUpdateAuthorityInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xd7, 0xe4, 0xa6, 0xe4, 0x54, 0x64, 0x56, 0x7b]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateTokenMetadataUpdateAuthorityInstructionData(
        newUpdateAuthority: map['newUpdateAuthority'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateTokenMetadataUpdateAuthorityInstructionData>(
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
      VariableSizeDecoder<UpdateTokenMetadataUpdateAuthorityInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateTokenMetadataUpdateAuthorityInstructionData,
  UpdateTokenMetadataUpdateAuthorityInstructionData
>
getUpdateTokenMetadataUpdateAuthorityInstructionDataCodec() {
  return combineCodec(
    getUpdateTokenMetadataUpdateAuthorityInstructionDataEncoder(),
    getUpdateTokenMetadataUpdateAuthorityInstructionDataDecoder(),
  );
}

/// Creates a [UpdateTokenMetadataUpdateAuthority] instruction.
Instruction getUpdateTokenMetadataUpdateAuthorityInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required Address? newUpdateAuthority,
}) {
  final instructionData = UpdateTokenMetadataUpdateAuthorityInstructionData(
    newUpdateAuthority: newUpdateAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateTokenMetadataUpdateAuthorityInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateTokenMetadataUpdateAuthority] instruction from raw instruction data.
UpdateTokenMetadataUpdateAuthorityInstructionData
parseUpdateTokenMetadataUpdateAuthorityInstruction(Instruction instruction) {
  return getUpdateTokenMetadataUpdateAuthorityInstructionDataDecoder().decode(
    instruction.data!,
  );
}
