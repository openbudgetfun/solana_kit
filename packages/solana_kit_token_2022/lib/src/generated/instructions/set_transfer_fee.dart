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
class SetTransferFeeInstructionData {
  const SetTransferFeeInstructionData({
    this.discriminator = 26,
    this.transferFeeDiscriminator = 5,
    required this.transferFeeBasisPoints,
    required this.maximumFee,
  });

  final int discriminator;
  final int transferFeeDiscriminator;
  final int transferFeeBasisPoints;
  final BigInt maximumFee;
}

Encoder<SetTransferFeeInstructionData> getSetTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
    ('transferFeeBasisPoints', getU16Encoder()),
    ('maximumFee', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetTransferFeeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'transferFeeDiscriminator': value.transferFeeDiscriminator,
      'transferFeeBasisPoints': value.transferFeeBasisPoints,
      'maximumFee': value.maximumFee,
    },
  );
}

Decoder<SetTransferFeeInstructionData> getSetTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
    ('transferFeeBasisPoints', getU16Decoder()),
    ('maximumFee', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => SetTransferFeeInstructionData(
      discriminator: map['discriminator']! as int,
      transferFeeDiscriminator: map['transferFeeDiscriminator']! as int,
      transferFeeBasisPoints: map['transferFeeBasisPoints']! as int,
      maximumFee: map['maximumFee']! as BigInt,
    ),
  );
}

Codec<SetTransferFeeInstructionData, SetTransferFeeInstructionData> getSetTransferFeeInstructionDataCodec() {
  return combineCodec(getSetTransferFeeInstructionDataEncoder(), getSetTransferFeeInstructionDataDecoder());
}

/// Creates a [SetTransferFee] instruction.
Instruction getSetTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address transferFeeConfigAuthority,
  required int transferFeeBasisPoints,
  required BigInt maximumFee,
}) {
  final instructionData = SetTransferFeeInstructionData(
      transferFeeBasisPoints: transferFeeBasisPoints,
      maximumFee: maximumFee,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: transferFeeConfigAuthority, role: AccountRole.readonlySigner),
    ],
    data: getSetTransferFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetTransferFee] instruction from raw instruction data.
SetTransferFeeInstructionData parseSetTransferFeeInstruction(Instruction instruction) {
  return getSetTransferFeeInstructionDataDecoder().decode(instruction.data!);
}
