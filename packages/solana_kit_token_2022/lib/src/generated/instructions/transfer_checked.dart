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
class TransferCheckedInstructionData {
  const TransferCheckedInstructionData({
    this.discriminator = 12,
    required this.amount,
    required this.decimals,
  });

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<TransferCheckedInstructionData> getTransferCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<TransferCheckedInstructionData> getTransferCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => TransferCheckedInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
      decimals: map['decimals']! as int,
    ),
  );
}

Codec<TransferCheckedInstructionData, TransferCheckedInstructionData> getTransferCheckedInstructionDataCodec() {
  return combineCodec(getTransferCheckedInstructionDataEncoder(), getTransferCheckedInstructionDataDecoder());
}

/// Creates a [TransferChecked] instruction.
Instruction getTransferCheckedInstruction({
  required Address programAddress,
  required Address source,
  required Address mint,
  required Address destination,
  required Address authority,
  required BigInt amount,
  required int decimals,
}) {
  final instructionData = TransferCheckedInstructionData(
      amount: amount,
      decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: destination, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getTransferCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferChecked] instruction from raw instruction data.
TransferCheckedInstructionData parseTransferCheckedInstruction(Instruction instruction) {
  return getTransferCheckedInstructionDataDecoder().decode(instruction.data!);
}
