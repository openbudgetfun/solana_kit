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
class TransferInstructionData {
  const TransferInstructionData({
    this.discriminator = 3,
    required this.amount,
  });

  final int discriminator;
  final BigInt amount;
}

Encoder<TransferInstructionData> getTransferInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
    },
  );
}

Decoder<TransferInstructionData> getTransferInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => TransferInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<TransferInstructionData, TransferInstructionData> getTransferInstructionDataCodec() {
  return combineCodec(getTransferInstructionDataEncoder(), getTransferInstructionDataDecoder());
}

/// Creates a [Transfer] instruction.
Instruction getTransferInstruction({
  required Address programAddress,
  required Address source,
  required Address destination,
  required Address authority,
  required BigInt amount,
}) {
  final instructionData = TransferInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: destination, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getTransferInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Transfer] instruction from raw instruction data.
TransferInstructionData parseTransferInstruction(Instruction instruction) {
  return getTransferInstructionDataDecoder().decode(instruction.data!);
}
