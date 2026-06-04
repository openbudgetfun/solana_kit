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
class TransferSubscriptionInstructionData {
  const TransferSubscriptionInstructionData({
    this.discriminator = 10,
    required this.transferData,
  });

  final int discriminator;
  final TransferData transferData;
}

Encoder<TransferSubscriptionInstructionData>
getTransferSubscriptionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferData', getTransferDataEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferSubscriptionInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferData': value.transferData,
    },
  );
}

Decoder<TransferSubscriptionInstructionData>
getTransferSubscriptionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferData', getTransferDataDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        TransferSubscriptionInstructionData(
          discriminator: map['discriminator']! as int,
          transferData: map['transferData']! as TransferData,
        ),
  );
}

Codec<TransferSubscriptionInstructionData, TransferSubscriptionInstructionData>
getTransferSubscriptionInstructionDataCodec() {
  return combineCodec(
    getTransferSubscriptionInstructionDataEncoder(),
    getTransferSubscriptionInstructionDataDecoder(),
  );
}

/// Creates a [TransferSubscription] instruction.
Instruction getTransferSubscriptionInstruction({
  required Address programAddress,
  required Address subscriptionPda,
  required Address planPda,
  required Address subscriptionAuthority,
  required Address delegatorAta,
  required Address receiverAta,
  required Address caller,
  required Address tokenMint,
  required Address tokenProgram,
  required Address eventAuthority,
  required Address selfProgram,
  required TransferData transferData,
}) {
  final instructionData = TransferSubscriptionInstructionData(
    transferData: transferData,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: subscriptionPda, role: AccountRole.writable),
      AccountMeta(address: planPda, role: AccountRole.readonly),
      AccountMeta(address: subscriptionAuthority, role: AccountRole.readonly),
      AccountMeta(address: delegatorAta, role: AccountRole.writable),
      AccountMeta(address: receiverAta, role: AccountRole.writable),
      AccountMeta(address: caller, role: AccountRole.readonlySigner),
      AccountMeta(address: tokenMint, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: eventAuthority, role: AccountRole.readonly),
      AccountMeta(address: selfProgram, role: AccountRole.readonly),
    ],
    data: getTransferSubscriptionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [TransferSubscription] instruction from raw instruction data.
TransferSubscriptionInstructionData parseTransferSubscriptionInstruction(
  Instruction instruction,
) {
  return getTransferSubscriptionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
