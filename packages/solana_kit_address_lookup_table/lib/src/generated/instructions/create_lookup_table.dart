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
class CreateLookupTableInstructionData {
  const CreateLookupTableInstructionData({
    this.discriminator = 0,
    required this.recentSlot,
    required this.bump,
  });

  final int discriminator;
  final BigInt recentSlot;
  final int bump;
}

Encoder<CreateLookupTableInstructionData>
getCreateLookupTableInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('recentSlot', getU64Encoder()),
    ('bump', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateLookupTableInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'recentSlot': value.recentSlot,
      'bump': value.bump,
    },
  );
}

Decoder<CreateLookupTableInstructionData>
getCreateLookupTableInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('recentSlot', getU64Decoder()),
    ('bump', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateLookupTableInstructionData(
          discriminator: map['discriminator']! as int,
          recentSlot: map['recentSlot']! as BigInt,
          bump: map['bump']! as int,
        ),
  );
}

Codec<CreateLookupTableInstructionData, CreateLookupTableInstructionData>
getCreateLookupTableInstructionDataCodec() {
  return combineCodec(
    getCreateLookupTableInstructionDataEncoder(),
    getCreateLookupTableInstructionDataDecoder(),
  );
}

/// Creates a [CreateLookupTable] instruction.
Instruction getCreateLookupTableInstruction({
  required Address programAddress,
  required Address address,
  required Address authority,
  required Address payer,
  required Address systemProgram,
  required BigInt recentSlot,
  required int bump,
}) {
  final instructionData = CreateLookupTableInstructionData(
    recentSlot: recentSlot,
    bump: bump,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: address, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateLookupTableInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateLookupTable] instruction from raw instruction data.
CreateLookupTableInstructionData parseCreateLookupTableInstruction(
  Instruction instruction,
) {
  return getCreateLookupTableInstructionDataDecoder().decode(instruction.data!);
}
