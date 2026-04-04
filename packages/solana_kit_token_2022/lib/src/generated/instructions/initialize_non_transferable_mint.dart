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
class InitializeNonTransferableMintInstructionData {
  const InitializeNonTransferableMintInstructionData({
    this.discriminator = 32,
  });

  final int discriminator;
}

Encoder<InitializeNonTransferableMintInstructionData> getInitializeNonTransferableMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeNonTransferableMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<InitializeNonTransferableMintInstructionData> getInitializeNonTransferableMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeNonTransferableMintInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<InitializeNonTransferableMintInstructionData, InitializeNonTransferableMintInstructionData> getInitializeNonTransferableMintInstructionDataCodec() {
  return combineCodec(getInitializeNonTransferableMintInstructionDataEncoder(), getInitializeNonTransferableMintInstructionDataDecoder());
}

/// Creates a [InitializeNonTransferableMint] instruction.
Instruction getInitializeNonTransferableMintInstruction({
  required Address programAddress,
  required Address mint,

}) {
  final instructionData = InitializeNonTransferableMintInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeNonTransferableMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeNonTransferableMint] instruction from raw instruction data.
InitializeNonTransferableMintInstructionData parseInitializeNonTransferableMintInstruction(Instruction instruction) {
  return getInitializeNonTransferableMintInstructionDataDecoder().decode(instruction.data!);
}
