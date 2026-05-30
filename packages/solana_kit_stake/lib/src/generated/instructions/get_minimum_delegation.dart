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
class GetMinimumDelegationInstructionData {
  const GetMinimumDelegationInstructionData({this.discriminator = 13});

  final int discriminator;
}

Encoder<GetMinimumDelegationInstructionData>
getGetMinimumDelegationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (GetMinimumDelegationInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<GetMinimumDelegationInstructionData>
getGetMinimumDelegationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        GetMinimumDelegationInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<GetMinimumDelegationInstructionData, GetMinimumDelegationInstructionData>
getGetMinimumDelegationInstructionDataCodec() {
  return combineCodec(
    getGetMinimumDelegationInstructionDataEncoder(),
    getGetMinimumDelegationInstructionDataDecoder(),
  );
}

/// Creates a [GetMinimumDelegation] instruction.
Instruction getGetMinimumDelegationInstruction({
  required Address programAddress,
}) {
  final instructionData = GetMinimumDelegationInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [],
    data: getGetMinimumDelegationInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [GetMinimumDelegation] instruction from raw instruction data.
GetMinimumDelegationInstructionData parseGetMinimumDelegationInstruction(
  Instruction instruction,
) {
  return getGetMinimumDelegationInstructionDataDecoder().decode(
    instruction.data!,
  );
}
