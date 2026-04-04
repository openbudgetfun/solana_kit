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
class CreateNativeMintInstructionData {
  const CreateNativeMintInstructionData({
    this.discriminator = 31,
  });

  final int discriminator;
}

Encoder<CreateNativeMintInstructionData> getCreateNativeMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateNativeMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CreateNativeMintInstructionData> getCreateNativeMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => CreateNativeMintInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<CreateNativeMintInstructionData, CreateNativeMintInstructionData> getCreateNativeMintInstructionDataCodec() {
  return combineCodec(getCreateNativeMintInstructionDataEncoder(), getCreateNativeMintInstructionDataDecoder());
}

/// Creates a [CreateNativeMint] instruction.
Instruction getCreateNativeMintInstruction({
  required Address programAddress,
  required Address payer,
  required Address nativeMint,
  required Address systemProgram,

}) {
  final instructionData = CreateNativeMintInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: payer, role: AccountRole.writableSigner),
    AccountMeta(address: nativeMint, role: AccountRole.writable),
    AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateNativeMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateNativeMint] instruction from raw instruction data.
CreateNativeMintInstructionData parseCreateNativeMintInstruction(Instruction instruction) {
  return getCreateNativeMintInstructionDataDecoder().decode(instruction.data!);
}
