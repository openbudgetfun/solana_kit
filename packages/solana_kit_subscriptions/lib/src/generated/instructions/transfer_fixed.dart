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
class TransferFixedInstructionData {
  const TransferFixedInstructionData({
    this.discriminator = 4,
    required this.transferData,
  });

  final int discriminator;
  final TransferData transferData;
}

Encoder<TransferFixedInstructionData> getTransferFixedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferData', getTransferDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferFixedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferData': value.transferData,
    },
  );
}

Decoder<TransferFixedInstructionData> getTransferFixedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferData', getTransferDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        TransferFixedInstructionData(
          discriminator: map['discriminator']! as int,
          transferData: map['transferData']! as TransferData,
        ),
  );
}

Codec<TransferFixedInstructionData, TransferFixedInstructionData>
getTransferFixedInstructionDataCodec() {
  return combineCodec(
    getTransferFixedInstructionDataEncoder(),
    getTransferFixedInstructionDataDecoder(),
  );
}

/// Creates a [TransferFixed] instruction.
Instruction getTransferFixedInstruction({
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
  final instructionData = TransferFixedInstructionData(
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
    data: getTransferFixedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferFixed] instruction from raw instruction data.
TransferFixedInstructionData parseTransferFixedInstruction(
  Instruction instruction,
) {
  return getTransferFixedInstructionDataDecoder().decode(instruction.data!);
}
