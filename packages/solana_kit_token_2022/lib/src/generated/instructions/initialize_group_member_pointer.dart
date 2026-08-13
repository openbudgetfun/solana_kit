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
class InitializeGroupMemberPointerInstructionData {
  const InitializeGroupMemberPointerInstructionData({
    this.discriminator = 41,
    this.groupMemberPointerDiscriminator = 0,
    required this.authority,
    required this.memberAddress,
  });

  final int discriminator;
  final int groupMemberPointerDiscriminator;
  final Address? authority;
  final Address? memberAddress;
}

Encoder<InitializeGroupMemberPointerInstructionData> getInitializeGroupMemberPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('groupMemberPointerDiscriminator', getU8Encoder()),
    ('authority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('memberAddress', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeGroupMemberPointerInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'groupMemberPointerDiscriminator': value.groupMemberPointerDiscriminator,
      'authority': value.authority,
      'memberAddress': value.memberAddress,
    },
  );
}

Decoder<InitializeGroupMemberPointerInstructionData> getInitializeGroupMemberPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('groupMemberPointerDiscriminator', getU8Decoder()),
    ('authority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('memberAddress', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeGroupMemberPointerInstructionData(
      discriminator: map['discriminator']! as int,
      groupMemberPointerDiscriminator: map['groupMemberPointerDiscriminator']! as int,
      authority: map['authority'] as Address?,
      memberAddress: map['memberAddress'] as Address?,
    ),
  );
}

Codec<InitializeGroupMemberPointerInstructionData, InitializeGroupMemberPointerInstructionData> getInitializeGroupMemberPointerInstructionDataCodec() {
  return combineCodec(getInitializeGroupMemberPointerInstructionDataEncoder(), getInitializeGroupMemberPointerInstructionDataDecoder());
}

/// Creates a [InitializeGroupMemberPointer] instruction.
Instruction getInitializeGroupMemberPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required Address? memberAddress,
}) {
  final instructionData = InitializeGroupMemberPointerInstructionData(
      authority: authority,
      memberAddress: memberAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeGroupMemberPointerInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeGroupMemberPointer] instruction from raw instruction data.
InitializeGroupMemberPointerInstructionData parseInitializeGroupMemberPointerInstruction(Instruction instruction) {
  return getInitializeGroupMemberPointerInstructionDataDecoder().decode(instruction.data!);
}
