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
class DeployWithMaxDataLenInstructionData {
  const DeployWithMaxDataLenInstructionData({
    this.discriminator = 2,
    required this.maxDataLen,
  });

  final int discriminator;
  final BigInt maxDataLen;
}

Encoder<DeployWithMaxDataLenInstructionData>
getDeployWithMaxDataLenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('maxDataLen', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeployWithMaxDataLenInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'maxDataLen': value.maxDataLen,
    },
  );
}

Decoder<DeployWithMaxDataLenInstructionData>
getDeployWithMaxDataLenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('maxDataLen', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        DeployWithMaxDataLenInstructionData(
          discriminator: map['discriminator']! as int,
          maxDataLen: map['maxDataLen']! as BigInt,
        ),
  );
}

Codec<DeployWithMaxDataLenInstructionData, DeployWithMaxDataLenInstructionData>
getDeployWithMaxDataLenInstructionDataCodec() {
  return combineCodec(
    getDeployWithMaxDataLenInstructionDataEncoder(),
    getDeployWithMaxDataLenInstructionDataDecoder(),
  );
}

/// Creates a [DeployWithMaxDataLen] instruction.
Instruction getDeployWithMaxDataLenInstruction({
  required Address programAddress,
  required Address payerAccount,
  required Address programDataAccount,
  required Address programAccount,
  required Address bufferAccount,
  required Address rentSysvar,
  required Address clockSysvar,
  required Address systemProgram,
  required Address authority,
  required BigInt maxDataLen,
}) {
  final instructionData = DeployWithMaxDataLenInstructionData(
    maxDataLen: maxDataLen,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payerAccount, role: AccountRole.writableSigner),
      AccountMeta(address: programDataAccount, role: AccountRole.writable),
      AccountMeta(address: programAccount, role: AccountRole.writable),
      AccountMeta(address: bufferAccount, role: AccountRole.writable),
      AccountMeta(address: rentSysvar, role: AccountRole.readonly),
      AccountMeta(address: clockSysvar, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getDeployWithMaxDataLenInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DeployWithMaxDataLen] instruction from raw instruction data.
DeployWithMaxDataLenInstructionData parseDeployWithMaxDataLenInstruction(
  Instruction instruction,
) {
  return getDeployWithMaxDataLenInstructionDataDecoder().decode(
    instruction.data!,
  );
}
