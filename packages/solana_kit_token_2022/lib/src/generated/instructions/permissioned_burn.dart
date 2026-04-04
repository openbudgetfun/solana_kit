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

/// The discriminator field name: 'permissionedBurnDiscriminator'.
/// Offset: 1.

@immutable
class PermissionedBurnInstructionData {
  const PermissionedBurnInstructionData({
    this.discriminator = 46,
    this.permissionedBurnDiscriminator = 1,
    required this.amount,
  });

  final int discriminator;
  final int permissionedBurnDiscriminator;
  final BigInt amount;
}

Encoder<PermissionedBurnInstructionData> getPermissionedBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('permissionedBurnDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PermissionedBurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'permissionedBurnDiscriminator': value.permissionedBurnDiscriminator,
      'amount': value.amount,
    },
  );
}

Decoder<PermissionedBurnInstructionData> getPermissionedBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('permissionedBurnDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => PermissionedBurnInstructionData(
      discriminator: map['discriminator']! as int,
      permissionedBurnDiscriminator: map['permissionedBurnDiscriminator']! as int,
      amount: map['amount']! as BigInt,
    ),
  );
}

Codec<PermissionedBurnInstructionData, PermissionedBurnInstructionData> getPermissionedBurnInstructionDataCodec() {
  return combineCodec(getPermissionedBurnInstructionDataEncoder(), getPermissionedBurnInstructionDataDecoder());
}

/// Creates a [PermissionedBurn] instruction.
Instruction getPermissionedBurnInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address permissionedBurnAuthority,
  required Address authority,
  required BigInt amount,
}) {
  final instructionData = PermissionedBurnInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: permissionedBurnAuthority, role: AccountRole.readonlySigner),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getPermissionedBurnInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [PermissionedBurn] instruction from raw instruction data.
PermissionedBurnInstructionData parsePermissionedBurnInstruction(Instruction instruction) {
  return getPermissionedBurnInstructionDataDecoder().decode(instruction.data!);
}
