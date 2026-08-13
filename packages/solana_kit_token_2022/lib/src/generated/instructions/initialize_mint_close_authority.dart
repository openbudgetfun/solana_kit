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
class InitializeMintCloseAuthorityInstructionData {
  const InitializeMintCloseAuthorityInstructionData({
    this.discriminator = 25,
    required this.closeAuthority,
  });

  final int discriminator;
  final Address? closeAuthority;
}

Encoder<InitializeMintCloseAuthorityInstructionData> getInitializeMintCloseAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('closeAuthority', getNullableEncoder<Address>(getAddressEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMintCloseAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'closeAuthority': value.closeAuthority,
    },
  );
}

Decoder<InitializeMintCloseAuthorityInstructionData> getInitializeMintCloseAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('closeAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeMintCloseAuthorityInstructionData(
      discriminator: map['discriminator']! as int,
      closeAuthority: map['closeAuthority'] as Address?,
    ),
  );
}

Codec<InitializeMintCloseAuthorityInstructionData, InitializeMintCloseAuthorityInstructionData> getInitializeMintCloseAuthorityInstructionDataCodec() {
  return combineCodec(getInitializeMintCloseAuthorityInstructionDataEncoder(), getInitializeMintCloseAuthorityInstructionDataDecoder());
}

/// Creates a [InitializeMintCloseAuthority] instruction.
Instruction getInitializeMintCloseAuthorityInstruction({
  required Address programAddress,
  required Address mint,
  required Address? closeAuthority,
}) {
  final instructionData = InitializeMintCloseAuthorityInstructionData(
      closeAuthority: closeAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeMintCloseAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeMintCloseAuthority] instruction from raw instruction data.
InitializeMintCloseAuthorityInstructionData parseInitializeMintCloseAuthorityInstruction(Instruction instruction) {
  return getInitializeMintCloseAuthorityInstructionDataDecoder().decode(instruction.data!);
}
