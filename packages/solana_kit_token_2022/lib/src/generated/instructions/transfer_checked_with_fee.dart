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

/// The discriminator field name: 'transferFeeDiscriminator'.
/// Offset: 1.

@immutable
class TransferCheckedWithFeeInstructionData {
  const TransferCheckedWithFeeInstructionData({
    this.discriminator = 26,
    this.transferFeeDiscriminator = 1,
    required this.amount,
    required this.decimals,
    required this.fee,
  });

  final int discriminator;
  final int transferFeeDiscriminator;
  final BigInt amount;
  final int decimals;
  final BigInt fee;
}

Encoder<TransferCheckedWithFeeInstructionData> getTransferCheckedWithFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
    ('fee', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferCheckedWithFeeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferFeeDiscriminator': value.transferFeeDiscriminator,
      'amount': value.amount,
      'decimals': value.decimals,
      'fee': value.fee,
    },
  );
}

Decoder<TransferCheckedWithFeeInstructionData> getTransferCheckedWithFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
    ('fee', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => TransferCheckedWithFeeInstructionData(
      discriminator: map['discriminator']! as int,
      transferFeeDiscriminator: map['transferFeeDiscriminator']! as int,
      amount: map['amount']! as BigInt,
      decimals: map['decimals']! as int,
      fee: map['fee']! as BigInt,
    ),
  );
}

Codec<TransferCheckedWithFeeInstructionData, TransferCheckedWithFeeInstructionData> getTransferCheckedWithFeeInstructionDataCodec() {
  return combineCodec(getTransferCheckedWithFeeInstructionDataEncoder(), getTransferCheckedWithFeeInstructionDataDecoder());
}

/// Creates a [TransferCheckedWithFee] instruction.
Instruction getTransferCheckedWithFeeInstruction({
  required Address programAddress,
  required Address source,
  required Address mint,
  required Address destination,
  required Address authority,
  required BigInt amount,
  required int decimals,
  required BigInt fee,
}) {
  final instructionData = TransferCheckedWithFeeInstructionData(
      amount: amount,
      decimals: decimals,
      fee: fee,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: destination, role: AccountRole.writable),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getTransferCheckedWithFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferCheckedWithFee] instruction from raw instruction data.
TransferCheckedWithFeeInstructionData parseTransferCheckedWithFeeInstruction(Instruction instruction) {
  return getTransferCheckedWithFeeInstructionDataDecoder().decode(instruction.data!);
}
