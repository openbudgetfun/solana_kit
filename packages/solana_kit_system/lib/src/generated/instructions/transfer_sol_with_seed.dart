// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class TransferSolWithSeedInstructionData {
  const TransferSolWithSeedInstructionData({
    this.discriminator = 11,
    required this.amount,
    required this.fromSeed,
    required this.fromOwner,
  });

  final int discriminator;
  final BigInt amount;
  final String fromSeed;
  final Address fromOwner;
}

Encoder<TransferSolWithSeedInstructionData> getTransferSolWithSeedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('amount', getU64Encoder()),
    ('fromSeed', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('fromOwner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferSolWithSeedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'amount': value.amount,
      'fromSeed': value.fromSeed,
      'fromOwner': value.fromOwner,
    },
  );
}

Decoder<TransferSolWithSeedInstructionData> getTransferSolWithSeedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('amount', getU64Decoder()),
    ('fromSeed', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('fromOwner', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => TransferSolWithSeedInstructionData(
      discriminator: map['discriminator']! as int,
      amount: map['amount']! as BigInt,
      fromSeed: map['fromSeed']! as String,
      fromOwner: map['fromOwner']! as Address,
    ),
  );
}

Codec<TransferSolWithSeedInstructionData, TransferSolWithSeedInstructionData> getTransferSolWithSeedInstructionDataCodec() {
  return combineCodec(getTransferSolWithSeedInstructionDataEncoder(), getTransferSolWithSeedInstructionDataDecoder());
}

/// Creates a [TransferSolWithSeed] instruction.
Instruction getTransferSolWithSeedInstruction({
  required Address programAddress,
  required Address source,
  required Address baseAccount,
  required Address destination,
  required BigInt amount,
  required String fromSeed,
  required Address fromOwner,
}) {
  final instructionData = TransferSolWithSeedInstructionData(
      amount: amount,
      fromSeed: fromSeed,
      fromOwner: fromOwner,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: source, role: AccountRole.writable),
    AccountMeta(address: baseAccount, role: AccountRole.readonlySigner),
    AccountMeta(address: destination, role: AccountRole.writable),
    ],
    data: getTransferSolWithSeedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferSolWithSeed] instruction from raw instruction data.
TransferSolWithSeedInstructionData parseTransferSolWithSeedInstruction(Instruction instruction) {
  return getTransferSolWithSeedInstructionDataDecoder().decode(instruction.data!);
}
