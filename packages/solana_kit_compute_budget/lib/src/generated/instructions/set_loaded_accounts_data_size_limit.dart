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
class SetLoadedAccountsDataSizeLimitInstructionData {
  const SetLoadedAccountsDataSizeLimitInstructionData({
    this.discriminator = 4,
    required this.accountDataSizeLimit,
  });

  final int discriminator;
  final int accountDataSizeLimit;
}

Encoder<SetLoadedAccountsDataSizeLimitInstructionData> getSetLoadedAccountsDataSizeLimitInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('accountDataSizeLimit', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetLoadedAccountsDataSizeLimitInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'accountDataSizeLimit': value.accountDataSizeLimit,
    },
  );
}

Decoder<SetLoadedAccountsDataSizeLimitInstructionData> getSetLoadedAccountsDataSizeLimitInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('accountDataSizeLimit', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SetLoadedAccountsDataSizeLimitInstructionData(
      discriminator: map['discriminator']! as int,
      accountDataSizeLimit: map['accountDataSizeLimit']! as int,
    ),
  );
}

Codec<SetLoadedAccountsDataSizeLimitInstructionData, SetLoadedAccountsDataSizeLimitInstructionData> getSetLoadedAccountsDataSizeLimitInstructionDataCodec() {
  return combineCodec(getSetLoadedAccountsDataSizeLimitInstructionDataEncoder(), getSetLoadedAccountsDataSizeLimitInstructionDataDecoder());
}

/// Creates a [SetLoadedAccountsDataSizeLimit] instruction.
Instruction getSetLoadedAccountsDataSizeLimitInstruction({
  required Address programAddress,

  required int accountDataSizeLimit,
}) {
  final instructionData = SetLoadedAccountsDataSizeLimitInstructionData(
      accountDataSizeLimit: accountDataSizeLimit,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [

    ],
    data: getSetLoadedAccountsDataSizeLimitInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetLoadedAccountsDataSizeLimit] instruction from raw instruction data.
SetLoadedAccountsDataSizeLimitInstructionData parseSetLoadedAccountsDataSizeLimitInstruction(Instruction instruction) {
  return getSetLoadedAccountsDataSizeLimitInstructionDataDecoder().decode(instruction.data!);
}
