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

/// The discriminator field name: 'groupPointerDiscriminator'.
/// Offset: 1.

@immutable
class UpdateGroupPointerInstructionData {
  const UpdateGroupPointerInstructionData({
    required this.groupAddress,
  }) : discriminator = 40,
       groupPointerDiscriminator = 1;

  final int discriminator;
  final int groupPointerDiscriminator;
  final Address? groupAddress;
}

Encoder<UpdateGroupPointerInstructionData>
getUpdateGroupPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('groupPointerDiscriminator', getU8Encoder()),
    (
      'groupAddress',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateGroupPointerInstructionData value) => <String, Object?>{
      'discriminator': 40,
      'groupPointerDiscriminator': 1,
      'groupAddress': value.groupAddress,
    },
  );
}

Decoder<UpdateGroupPointerInstructionData>
getUpdateGroupPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('groupPointerDiscriminator', getU8Decoder()),
    (
      'groupAddress',
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
        'codecDescription': 'updateGroupPointer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateGroupPointerInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(40),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateGroupPointerInstructionData(
        groupAddress: map['groupAddress'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateGroupPointerInstructionData>(
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
      VariableSizeDecoder<UpdateGroupPointerInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateGroupPointerInstructionData, UpdateGroupPointerInstructionData>
getUpdateGroupPointerInstructionDataCodec() {
  return combineCodec(
    getUpdateGroupPointerInstructionDataEncoder(),
    getUpdateGroupPointerInstructionDataDecoder(),
  );
}

/// Creates a [UpdateGroupPointer] instruction.
/// Set [groupPointerAuthorityIsSigner] to false when [groupPointerAuthority] does not sign (for example, a multisig authority).
Instruction getUpdateGroupPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address groupPointerAuthority,
  required Address? groupAddress,
  bool groupPointerAuthorityIsSigner = true,
}) {
  final instructionData = UpdateGroupPointerInstructionData(
    groupAddress: groupAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: groupPointerAuthority,
        role: groupPointerAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getUpdateGroupPointerInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateGroupPointer] instruction from raw instruction data.
UpdateGroupPointerInstructionData parseUpdateGroupPointerInstruction(
  Instruction instruction,
) {
  return getUpdateGroupPointerInstructionDataDecoder().decode(
    instruction.data!,
  );
}
