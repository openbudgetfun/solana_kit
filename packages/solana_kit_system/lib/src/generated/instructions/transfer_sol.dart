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
class TransferSolInstructionData {
  const TransferSolInstructionData({
    this.discriminator = 2,
    required this.amount,
  });

  final int discriminator;
  final BigInt amount;
}

Encoder<TransferSolInstructionData> getTransferSolInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferSolInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<TransferSolInstructionData> getTransferSolInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => TransferSolInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<TransferSolInstructionData, TransferSolInstructionData> getTransferSolInstructionDataCodec() {
  return combineCodec(getTransferSolInstructionDataEncoder(), getTransferSolInstructionDataDecoder());
}

/// Creates a [TransferSol] instruction.
Instruction getTransferSolInstruction({
  required Address programAddress,
  required Address source,
  required Address destination,
  required BigInt amount,
}) {
  final instructionData = TransferSolInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writableSigner),
    AccountMeta(address: destination, role: AccountRole.writable),
    ],
    data: getTransferSolInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferSol] instruction from raw instruction data.
TransferSolInstructionData parseTransferSolInstruction(Instruction instruction) {
  return getTransferSolInstructionDataDecoder().decode(instruction.data!);
}
