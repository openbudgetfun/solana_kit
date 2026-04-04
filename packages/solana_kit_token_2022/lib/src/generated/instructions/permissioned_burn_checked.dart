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
class PermissionedBurnCheckedInstructionData {
  const PermissionedBurnCheckedInstructionData({
    this.discriminator = 46,
    this.permissionedBurnDiscriminator = 2,
    required this.amount,
    required this.decimals,
  });

  final int discriminator;
  final int permissionedBurnDiscriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<PermissionedBurnCheckedInstructionData> getPermissionedBurnCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('permissionedBurnDiscriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PermissionedBurnCheckedInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'permissionedBurnDiscriminator': value.permissionedBurnDiscriminator,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<PermissionedBurnCheckedInstructionData> getPermissionedBurnCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('permissionedBurnDiscriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => PermissionedBurnCheckedInstructionData(
      discriminator: map['discriminator']! as int,
      permissionedBurnDiscriminator: map['permissionedBurnDiscriminator']! as int,
      amount: map['amount']! as BigInt,
      decimals: map['decimals']! as int,
    ),
  );
}

Codec<PermissionedBurnCheckedInstructionData, PermissionedBurnCheckedInstructionData> getPermissionedBurnCheckedInstructionDataCodec() {
  return combineCodec(getPermissionedBurnCheckedInstructionDataEncoder(), getPermissionedBurnCheckedInstructionDataDecoder());
}

/// Creates a [PermissionedBurnChecked] instruction.
Instruction getPermissionedBurnCheckedInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address permissionedBurnAuthority,
  required Address authority,
  required BigInt amount,
  required int decimals,
}) {
  final instructionData = PermissionedBurnCheckedInstructionData(
      amount: amount,
      decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: account, role: AccountRole.writable),
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: permissionedBurnAuthority, role: AccountRole.readonlySigner),
    AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getPermissionedBurnCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [PermissionedBurnChecked] instruction from raw instruction data.
PermissionedBurnCheckedInstructionData parsePermissionedBurnCheckedInstruction(Instruction instruction) {
  return getPermissionedBurnCheckedInstructionDataDecoder().decode(instruction.data!);
}
