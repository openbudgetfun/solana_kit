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
class UnwrapLamportsInstructionData {
  const UnwrapLamportsInstructionData({
    this.discriminator = 45,
    required this.amount,
  });

  final int discriminator;
  final BigInt? amount;
}

Encoder<UnwrapLamportsInstructionData> getUnwrapLamportsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getNullableEncoder<BigInt>(getU64Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (UnwrapLamportsInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<UnwrapLamportsInstructionData> getUnwrapLamportsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UnwrapLamportsInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount'] as BigInt?,
    ),
  );
}

Codec<UnwrapLamportsInstructionData, UnwrapLamportsInstructionData> getUnwrapLamportsInstructionDataCodec() {
  return combineCodec(getUnwrapLamportsInstructionDataEncoder(), getUnwrapLamportsInstructionDataDecoder());
}

/// Creates a [UnwrapLamports] instruction.
Instruction getUnwrapLamportsInstruction({
  required Address programAddress,
  required Address source,
  required Address destination,
  required Address authority,
  required BigInt? amount,
}) {
  final instructionData = UnwrapLamportsInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: destination, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getUnwrapLamportsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UnwrapLamports] instruction from raw instruction data.
UnwrapLamportsInstructionData parseUnwrapLamportsInstruction(Instruction instruction) {
  return getUnwrapLamportsInstructionDataDecoder().decode(instruction.data!);
}
