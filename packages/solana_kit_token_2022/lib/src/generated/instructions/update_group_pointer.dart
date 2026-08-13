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

/// The discriminator field name: 'groupPointerDiscriminator'.
/// Offset: 1.

@immutable
class UpdateGroupPointerInstructionData {
  const UpdateGroupPointerInstructionData({
    this.discriminator = 40,
    this.groupPointerDiscriminator = 1,
    required this.groupAddress,
  });

  final int discriminator;
  final int groupPointerDiscriminator;
  final Address? groupAddress;
}

Encoder<UpdateGroupPointerInstructionData> getUpdateGroupPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('groupPointerDiscriminator', getU8Encoder()),
    ('groupAddress', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateGroupPointerInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'groupPointerDiscriminator': value.groupPointerDiscriminator,
      'groupAddress': value.groupAddress,
    },
  );
}

Decoder<UpdateGroupPointerInstructionData> getUpdateGroupPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('groupPointerDiscriminator', getU8Decoder()),
    ('groupAddress', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateGroupPointerInstructionData(
      discriminator: map['discriminator']! as int,
      groupPointerDiscriminator: map['groupPointerDiscriminator']! as int,
      groupAddress: map['groupAddress'] as Address?,
    ),
  );
}

Codec<UpdateGroupPointerInstructionData, UpdateGroupPointerInstructionData> getUpdateGroupPointerInstructionDataCodec() {
  return combineCodec(getUpdateGroupPointerInstructionDataEncoder(), getUpdateGroupPointerInstructionDataDecoder());
}

/// Creates a [UpdateGroupPointer] instruction.
Instruction getUpdateGroupPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address groupPointerAuthority,
  required Address? groupAddress,
}) {
  final instructionData = UpdateGroupPointerInstructionData(
      groupAddress: groupAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: groupPointerAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateGroupPointerInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateGroupPointer] instruction from raw instruction data.
UpdateGroupPointerInstructionData parseUpdateGroupPointerInstruction(Instruction instruction) {
  return getUpdateGroupPointerInstructionDataDecoder().decode(instruction.data!);
}
