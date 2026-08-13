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
class CloseInstructionData {
  const CloseInstructionData({
    this.discriminator = 5,
  });

  final int discriminator;
}

Encoder<CloseInstructionData> getCloseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CloseInstructionData> getCloseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CloseInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<CloseInstructionData, CloseInstructionData> getCloseInstructionDataCodec() {
  return combineCodec(getCloseInstructionDataEncoder(), getCloseInstructionDataDecoder());
}

/// Creates a [Close] instruction.
Instruction getCloseInstruction({
  required Address programAddress,
  required Address bufferOrProgramDataAccount,
  required Address destinationAccount,
  Address? authority,
  Address? programAccount,

}) {
  final instructionData = CloseInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: bufferOrProgramDataAccount, role: AccountRole.writable),
    AccountMeta(address: destinationAccount, role: AccountRole.writable),
    if (authority != null) AccountMeta(address: authority, role: AccountRole.readonlySigner),
    if (programAccount != null) AccountMeta(address: programAccount, role: AccountRole.readonly),
    ],
    data: getCloseInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Close] instruction from raw instruction data.
CloseInstructionData parseCloseInstruction(Instruction instruction) {
  return getCloseInstructionDataDecoder().decode(instruction.data!);
}
