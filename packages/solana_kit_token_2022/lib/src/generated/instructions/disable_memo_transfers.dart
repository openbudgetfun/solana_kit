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

/// The discriminator field name: 'memoTransfersDiscriminator'.
/// Offset: 1.

@immutable
class DisableMemoTransfersInstructionData {
  const DisableMemoTransfersInstructionData({
    this.discriminator = 30,
    this.memoTransfersDiscriminator = 1,
  });

  final int discriminator;
  final int memoTransfersDiscriminator;
}

Encoder<DisableMemoTransfersInstructionData> getDisableMemoTransfersInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('memoTransfersDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DisableMemoTransfersInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'memoTransfersDiscriminator': value.memoTransfersDiscriminator,
    },
  );
}

Decoder<DisableMemoTransfersInstructionData> getDisableMemoTransfersInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('memoTransfersDiscriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => DisableMemoTransfersInstructionData(
      discriminator: map['discriminator']! as int,
      memoTransfersDiscriminator: map['memoTransfersDiscriminator']! as int,
    ),
  );
}

Codec<DisableMemoTransfersInstructionData, DisableMemoTransfersInstructionData> getDisableMemoTransfersInstructionDataCodec() {
  return combineCodec(getDisableMemoTransfersInstructionDataEncoder(), getDisableMemoTransfersInstructionDataDecoder());
}

/// Creates a [DisableMemoTransfers] instruction.
Instruction getDisableMemoTransfersInstruction({
  required Address programAddress,
  required Address token,
  required Address owner,

}) {
  final instructionData = DisableMemoTransfersInstructionData(

  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: token, role: AccountRole.writable),
    AccountMeta(address: owner, role: AccountRole.readonlySigner),
    ],
    data: getDisableMemoTransfersInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [DisableMemoTransfers] instruction from raw instruction data.
DisableMemoTransfersInstructionData parseDisableMemoTransfersInstruction(Instruction instruction) {
  return getDisableMemoTransfersInstructionDataDecoder().decode(instruction.data!);
}
