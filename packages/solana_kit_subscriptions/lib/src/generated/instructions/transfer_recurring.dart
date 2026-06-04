// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/transfer_data.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class TransferRecurringInstructionData {
  const TransferRecurringInstructionData({
    this.discriminator = 5,
    required this.transferData,
  });

  final int discriminator;
  final TransferData transferData;
}

Encoder<TransferRecurringInstructionData>
getTransferRecurringInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferData', getTransferDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferRecurringInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferData': value.transferData,
    },
  );
}

Decoder<TransferRecurringInstructionData>
getTransferRecurringInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferData', getTransferDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        TransferRecurringInstructionData(
          discriminator: map['discriminator']! as int,
          transferData: map['transferData']! as TransferData,
        ),
  );
}

Codec<TransferRecurringInstructionData, TransferRecurringInstructionData>
getTransferRecurringInstructionDataCodec() {
  return combineCodec(
    getTransferRecurringInstructionDataEncoder(),
    getTransferRecurringInstructionDataDecoder(),
  );
}

/// Creates a [TransferRecurring] instruction.
Instruction getTransferRecurringInstruction({
  required Address programAddress,
  required Address delegationPda,
  required Address subscriptionAuthority,
  required Address delegatorAta,
  required Address receiverAta,
  required Address tokenMint,
  required Address tokenProgram,
  required Address delegatee,
  required Address eventAuthority,
  required Address selfProgram,
  required TransferData transferData,
}) {
  final instructionData = TransferRecurringInstructionData(
    transferData: transferData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: delegationPda, role: AccountRole.writable),
      AccountMeta(address: subscriptionAuthority, role: AccountRole.readonly),
      AccountMeta(address: delegatorAta, role: AccountRole.writable),
      AccountMeta(address: receiverAta, role: AccountRole.writable),
      AccountMeta(address: tokenMint, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: delegatee, role: AccountRole.readonlySigner),
      AccountMeta(address: eventAuthority, role: AccountRole.readonly),
      AccountMeta(address: selfProgram, role: AccountRole.readonly),
    ],
    data: getTransferRecurringInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferRecurring] instruction from raw instruction data.
TransferRecurringInstructionData parseTransferRecurringInstruction(
  Instruction instruction,
) {
  return getTransferRecurringInstructionDataDecoder().decode(instruction.data!);
}
