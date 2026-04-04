// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateTokenGroupUpdateAuthorityInstructionData {
  UpdateTokenGroupUpdateAuthorityInstructionData({
    Uint8List? discriminator,
    required this.newUpdateAuthority,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([161, 105, 88, 1, 237, 221, 216, 203]);

  final Uint8List discriminator;
  final Address? newUpdateAuthority;
}

Encoder<UpdateTokenGroupUpdateAuthorityInstructionData> getUpdateTokenGroupUpdateAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('newUpdateAuthority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTokenGroupUpdateAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newUpdateAuthority': value.newUpdateAuthority,
    },
  );
}

Decoder<UpdateTokenGroupUpdateAuthorityInstructionData> getUpdateTokenGroupUpdateAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('newUpdateAuthority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateTokenGroupUpdateAuthorityInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      newUpdateAuthority: map['newUpdateAuthority'] as Address?,
    ),
  );
}

Codec<UpdateTokenGroupUpdateAuthorityInstructionData, UpdateTokenGroupUpdateAuthorityInstructionData> getUpdateTokenGroupUpdateAuthorityInstructionDataCodec() {
  return combineCodec(getUpdateTokenGroupUpdateAuthorityInstructionDataEncoder(), getUpdateTokenGroupUpdateAuthorityInstructionDataDecoder());
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
    data: getUpdateTokenGroupUpdateAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateTokenGroupUpdateAuthority] instruction from raw instruction data.
UpdateTokenGroupUpdateAuthorityInstructionData parseUpdateTokenGroupUpdateAuthorityInstruction(Instruction instruction) {
  return getUpdateTokenGroupUpdateAuthorityInstructionDataDecoder().decode(instruction.data!);
}
