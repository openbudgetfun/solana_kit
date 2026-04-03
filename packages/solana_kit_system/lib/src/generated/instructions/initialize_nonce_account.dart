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
class InitializeNonceAccountInstructionData {
  const InitializeNonceAccountInstructionData({
    this.discriminator = 6,
    required this.nonceAuthority,
  });

  final int discriminator;
  final Address nonceAuthority;
}

Encoder<InitializeNonceAccountInstructionData> getInitializeNonceAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('nonceAuthority', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeNonceAccountInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'nonceAuthority': value.nonceAuthority,
    },
  );
}

Decoder<InitializeNonceAccountInstructionData> getInitializeNonceAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('nonceAuthority', getAddressDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeNonceAccountInstructionData(
      discriminator: map['discriminator']! as int,
      nonceAuthority: map['nonceAuthority']! as Address,
    ),
  );
}

Codec<InitializeNonceAccountInstructionData, InitializeNonceAccountInstructionData> getInitializeNonceAccountInstructionDataCodec() {
  return combineCodec(getInitializeNonceAccountInstructionDataEncoder(), getInitializeNonceAccountInstructionDataDecoder());
}

/// Creates a [InitializeNonceAccount] instruction.
Instruction getInitializeNonceAccountInstruction({
  required Address programAddress,
  required Address nonceAccount,
  required Address recentBlockhashesSysvar,
  required Address rentSysvar,
  required Address nonceAuthority,
}) {
  final instructionData = InitializeNonceAccountInstructionData(
      nonceAuthority: nonceAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: nonceAccount, role: AccountRole.writable),
    AccountMeta(address: recentBlockhashesSysvar, role: AccountRole.readonly),
    AccountMeta(address: rentSysvar, role: AccountRole.readonly),
    ],
    data: getInitializeNonceAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeNonceAccount] instruction from raw instruction data.
InitializeNonceAccountInstructionData parseInitializeNonceAccountInstruction(Instruction instruction) {
  return getInitializeNonceAccountInstructionDataDecoder().decode(instruction.data!);
}
