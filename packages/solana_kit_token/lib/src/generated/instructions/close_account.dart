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

@immutable
class CloseAccountInstructionData {
  const CloseAccountInstructionData({
    this.discriminator = 9,
  });

  final int discriminator;
}

Encoder<CloseAccountInstructionData> getCloseAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CloseAccountInstructionData> getCloseAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CloseAccountInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<CloseAccountInstructionData, CloseAccountInstructionData> getCloseAccountInstructionDataCodec() {
  return combineCodec(getCloseAccountInstructionDataEncoder(), getCloseAccountInstructionDataDecoder());
}

/// Creates a [CloseAccount] instruction.
Instruction getCloseAccountInstruction({
  required Address programAddress,
  required Address account,
  required Address destination,
  required Address owner,

}) {
  final instructionData = CloseAccountInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: destination, role: AccountRole.writable),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getCloseAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseAccount] instruction from raw instruction data.
CloseAccountInstructionData parseCloseAccountInstruction(Instruction instruction) {
  return getCloseAccountInstructionDataDecoder().decode(instruction.data!);
}
