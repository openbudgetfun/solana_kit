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
class GetAccountDataSizeInstructionData {
  const GetAccountDataSizeInstructionData({
    this.discriminator = 21,
  });

  final int discriminator;
}

Encoder<GetAccountDataSizeInstructionData> getGetAccountDataSizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (GetAccountDataSizeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<GetAccountDataSizeInstructionData> getGetAccountDataSizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => GetAccountDataSizeInstructionData(
      discriminator: map['discriminator']! as int,
    ),
  );
}

Codec<GetAccountDataSizeInstructionData, GetAccountDataSizeInstructionData> getGetAccountDataSizeInstructionDataCodec() {
  return combineCodec(getGetAccountDataSizeInstructionDataEncoder(), getGetAccountDataSizeInstructionDataDecoder());
}

/// Creates a [GetAccountDataSize] instruction.
Instruction getGetAccountDataSizeInstruction({
  required Address programAddress,
  required Address mint,

}) {
  final instructionData = GetAccountDataSizeInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.readonly),
    ],
    data: getGetAccountDataSizeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [GetAccountDataSize] instruction from raw instruction data.
GetAccountDataSizeInstructionData parseGetAccountDataSizeInstruction(Instruction instruction) {
  return getGetAccountDataSizeInstructionDataDecoder().decode(instruction.data!);
}
