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
class InitializeTokenGroupMemberInstructionData {
  InitializeTokenGroupMemberInstructionData({
    Uint8List? discriminator,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([152, 32, 222, 176, 223, 237, 116, 134]);

  final Uint8List discriminator;
}

Encoder<InitializeTokenGroupMemberInstructionData> getInitializeTokenGroupMemberInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTokenGroupMemberInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<InitializeTokenGroupMemberInstructionData> getInitializeTokenGroupMemberInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeTokenGroupMemberInstructionData(
      discriminator: map['discriminator']! as Uint8List,
    ),
  );
}

Codec<InitializeTokenGroupMemberInstructionData, InitializeTokenGroupMemberInstructionData> getInitializeTokenGroupMemberInstructionDataCodec() {
  return combineCodec(getInitializeTokenGroupMemberInstructionDataEncoder(), getInitializeTokenGroupMemberInstructionDataDecoder());
}

/// Creates a [InitializeTokenGroupMember] instruction.
Instruction getInitializeTokenGroupMemberInstruction({
  required Address programAddress,
  required Address member,
  required Address memberMint,
  required Address memberMintAuthority,
  required Address group,
  required Address groupUpdateAuthority,

}) {
  final instructionData = InitializeTokenGroupMemberInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: member, role: AccountRole.writable),
    AccountMeta(address: memberMint, role: AccountRole.readonly),
    AccountMeta(address: memberMintAuthority, role: AccountRole.readonlySigner),
    AccountMeta(address: group, role: AccountRole.writable),
    AccountMeta(address: groupUpdateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getInitializeTokenGroupMemberInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeTokenGroupMember] instruction from raw instruction data.
InitializeTokenGroupMemberInstructionData parseInitializeTokenGroupMemberInstruction(Instruction instruction) {
  return getInitializeTokenGroupMemberInstructionDataDecoder().decode(instruction.data!);
}
