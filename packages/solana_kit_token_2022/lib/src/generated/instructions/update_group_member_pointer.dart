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

/// The discriminator field name: 'groupMemberPointerDiscriminator'.
/// Offset: 1.

@immutable
class UpdateGroupMemberPointerInstructionData {
  const UpdateGroupMemberPointerInstructionData({
    required this.memberAddress,
  }) : discriminator = 41,
       groupMemberPointerDiscriminator = 1;

  final int discriminator;
  final int groupMemberPointerDiscriminator;
  final Address? memberAddress;
}

Encoder<UpdateGroupMemberPointerInstructionData>
getUpdateGroupMemberPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('groupMemberPointerDiscriminator', getU8Encoder()),
    (
      'memberAddress',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateGroupMemberPointerInstructionData value) => <String, Object?>{
      'discriminator': 41,
      'groupMemberPointerDiscriminator': 1,
      'memberAddress': value.memberAddress,
    },
  );
}

Decoder<UpdateGroupMemberPointerInstructionData>
getUpdateGroupMemberPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('groupMemberPointerDiscriminator', getU8Decoder()),
    (
      'memberAddress',
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
        'codecDescription': 'updateGroupMemberPointer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateGroupMemberPointerInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(41),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateGroupMemberPointerInstructionData(
        memberAddress: map['memberAddress'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateGroupMemberPointerInstructionData>(
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
      VariableSizeDecoder<UpdateGroupMemberPointerInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateGroupMemberPointerInstructionData,
  UpdateGroupMemberPointerInstructionData
>
getUpdateGroupMemberPointerInstructionDataCodec() {
  return combineCodec(
    getUpdateGroupMemberPointerInstructionDataEncoder(),
    getUpdateGroupMemberPointerInstructionDataDecoder(),
  );
}

/// Creates a [UpdateGroupMemberPointer] instruction.
/// Set [groupMemberPointerAuthorityIsSigner] to false when [groupMemberPointerAuthority] does not sign (for example, a multisig authority).
Instruction getUpdateGroupMemberPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address groupMemberPointerAuthority,
  required Address? memberAddress,
  bool groupMemberPointerAuthorityIsSigner = true,
}) {
  final instructionData = UpdateGroupMemberPointerInstructionData(
    memberAddress: memberAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: groupMemberPointerAuthority,
        role: groupMemberPointerAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getUpdateGroupMemberPointerInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateGroupMemberPointer] instruction from raw instruction data.
UpdateGroupMemberPointerInstructionData
parseUpdateGroupMemberPointerInstruction(Instruction instruction) {
  return getUpdateGroupMemberPointerInstructionDataDecoder().decode(
    instruction.data!,
  );
}
