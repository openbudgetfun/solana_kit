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
class InitializePermissionedBurnInstructionData {
  const InitializePermissionedBurnInstructionData({
    this.discriminator = 46,
    this.permissionedBurnDiscriminator = 0,
    required this.authority,
  });

  final int discriminator;
  final int permissionedBurnDiscriminator;
  final Address authority;
}

Encoder<InitializePermissionedBurnInstructionData> getInitializePermissionedBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('permissionedBurnDiscriminator', getU8Encoder()),
    ('authority', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializePermissionedBurnInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'permissionedBurnDiscriminator': value.permissionedBurnDiscriminator,
      'authority': value.authority,
    },
  );
}

Decoder<InitializePermissionedBurnInstructionData> getInitializePermissionedBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('permissionedBurnDiscriminator', getU8Decoder()),
    ('authority', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializePermissionedBurnInstructionData(
      discriminator: map['discriminator']! as int,
      permissionedBurnDiscriminator: map['permissionedBurnDiscriminator']! as int,
      authority: map['authority']! as Address,
    ),
  );
}

Codec<InitializePermissionedBurnInstructionData, InitializePermissionedBurnInstructionData> getInitializePermissionedBurnInstructionDataCodec() {
  return combineCodec(getInitializePermissionedBurnInstructionDataEncoder(), getInitializePermissionedBurnInstructionDataDecoder());
}

/// Creates a [InitializePermissionedBurn] instruction.
Instruction getInitializePermissionedBurnInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
}) {
  final instructionData = InitializePermissionedBurnInstructionData(
      authority: authority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializePermissionedBurnInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializePermissionedBurn] instruction from raw instruction data.
InitializePermissionedBurnInstructionData parseInitializePermissionedBurnInstruction(Instruction instruction) {
  return getInitializePermissionedBurnInstructionDataDecoder().decode(instruction.data!);
}
