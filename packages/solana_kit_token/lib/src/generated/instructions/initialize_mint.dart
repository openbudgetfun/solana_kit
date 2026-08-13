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
class InitializeMintInstructionData {
  const InitializeMintInstructionData({
    this.discriminator = 0,
    required this.decimals,
    required this.mintAuthority,
    required this.freezeAuthority,
  });

  final int discriminator;
  final int decimals;
  final Address mintAuthority;
  final Address? freezeAuthority;
}

Encoder<InitializeMintInstructionData> getInitializeMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('decimals', getU8Encoder()),
    ('mintAuthority', getAddressEncoder()),
    ('freezeAuthority', getNullableEncoder<Address>(getAddressEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'decimals': value.decimals,
      'mintAuthority': value.mintAuthority,
      'freezeAuthority': value.freezeAuthority,
    },
  );
}

Decoder<InitializeMintInstructionData> getInitializeMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('decimals', getU8Decoder()),
    ('mintAuthority', getAddressDecoder()),
    ('freezeAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeMintInstructionData(
      discriminator: map['discriminator']! as int,
      decimals: map['decimals']! as int,
      mintAuthority: map['mintAuthority']! as Address,
      freezeAuthority: map['freezeAuthority'] as Address?,
    ),
  );
}

Codec<InitializeMintInstructionData, InitializeMintInstructionData> getInitializeMintInstructionDataCodec() {
  return combineCodec(getInitializeMintInstructionDataEncoder(), getInitializeMintInstructionDataDecoder());
}

/// Creates a [InitializeMint] instruction.
Instruction getInitializeMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address rent,
  required int decimals,
  required Address mintAuthority,
  Address? freezeAuthority,
}) {
  final instructionData = InitializeMintInstructionData(
      decimals: decimals,
      mintAuthority: mintAuthority,
      freezeAuthority: freezeAuthority ?? null,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getInitializeMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeMint] instruction from raw instruction data.
InitializeMintInstructionData parseInitializeMintInstruction(Instruction instruction) {
  return getInitializeMintInstructionDataDecoder().decode(instruction.data!);
}
