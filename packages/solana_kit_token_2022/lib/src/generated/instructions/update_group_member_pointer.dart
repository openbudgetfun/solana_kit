// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'groupMemberPointerDiscriminator'.
/// Offset: 1.

@immutable
class UpdateGroupMemberPointerInstructionData {
  const UpdateGroupMemberPointerInstructionData({
    this.discriminator = 41,
    this.groupMemberPointerDiscriminator = 1,
    required this.memberAddress,
  });

  final int discriminator;
  final int groupMemberPointerDiscriminator;
  final Address? memberAddress;
}

Encoder<UpdateGroupMemberPointerInstructionData> getUpdateGroupMemberPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('groupMemberPointerDiscriminator', getU8Encoder()),
    ('memberAddress', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateGroupMemberPointerInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'groupMemberPointerDiscriminator': value.groupMemberPointerDiscriminator,
      'memberAddress': value.memberAddress,
    },
  );
}

Decoder<UpdateGroupMemberPointerInstructionData> getUpdateGroupMemberPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('groupMemberPointerDiscriminator', getU8Decoder()),
    ('memberAddress', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateGroupMemberPointerInstructionData(
      discriminator: map['discriminator']! as int,
      groupMemberPointerDiscriminator: map['groupMemberPointerDiscriminator']! as int,
      memberAddress: map['memberAddress'] as Address?,
    ),
  );
}

Codec<UpdateGroupMemberPointerInstructionData, UpdateGroupMemberPointerInstructionData> getUpdateGroupMemberPointerInstructionDataCodec() {
  return combineCodec(getUpdateGroupMemberPointerInstructionDataEncoder(), getUpdateGroupMemberPointerInstructionDataDecoder());
}

/// Creates a [UpdateGroupMemberPointer] instruction.
Instruction getUpdateGroupMemberPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address groupMemberPointerAuthority,
  required Address? memberAddress,
}) {
  final instructionData = UpdateGroupMemberPointerInstructionData(
      memberAddress: memberAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: groupMemberPointerAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateGroupMemberPointerInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateGroupMemberPointer] instruction from raw instruction data.
UpdateGroupMemberPointerInstructionData parseUpdateGroupMemberPointerInstruction(Instruction instruction) {
  return getUpdateGroupMemberPointerInstructionDataDecoder().decode(instruction.data!);
}
