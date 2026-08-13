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
class InitializeAccount3InstructionData {
  const InitializeAccount3InstructionData({
    this.discriminator = 18,
    required this.owner,
  });

  final int discriminator;
  final Address owner;
}

Encoder<InitializeAccount3InstructionData> getInitializeAccount3InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('owner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeAccount3InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'owner': value.owner,
    },
  );
}

Decoder<InitializeAccount3InstructionData> getInitializeAccount3InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('owner', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeAccount3InstructionData(
      discriminator: map['discriminator']! as int,
      owner: map['owner']! as Address,
    ),
  );
}

Codec<InitializeAccount3InstructionData, InitializeAccount3InstructionData> getInitializeAccount3InstructionDataCodec() {
  return combineCodec(getInitializeAccount3InstructionDataEncoder(), getInitializeAccount3InstructionDataDecoder());
}

/// Creates a [InitializeAccount3] instruction.
Instruction getInitializeAccount3Instruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address owner,
}) {
  final instructionData = InitializeAccount3InstructionData(
      owner: owner,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    ],
    data: getInitializeAccount3InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeAccount3] instruction from raw instruction data.
InitializeAccount3InstructionData parseInitializeAccount3Instruction(Instruction instruction) {
  return getInitializeAccount3InstructionDataDecoder().decode(instruction.data!);
}
