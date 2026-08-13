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
class InitializeMint2InstructionData {
  const InitializeMint2InstructionData({
    this.discriminator = 20,
    required this.decimals,
    required this.mintAuthority,
    required this.freezeAuthority,
  });

  final int discriminator;
  final int decimals;
  final Address mintAuthority;
  final Address? freezeAuthority;
}

Encoder<InitializeMint2InstructionData> getInitializeMint2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('decimals', getU8Encoder()),
    ('mintAuthority', getAddressEncoder()),
    ('freezeAuthority', getNullableEncoder<Address>(getAddressEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMint2InstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'decimals': value.decimals,
      'mintAuthority': value.mintAuthority,
      'freezeAuthority': value.freezeAuthority,
    },
  );
}

Decoder<InitializeMint2InstructionData> getInitializeMint2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('decimals', getU8Decoder()),
    ('mintAuthority', getAddressDecoder()),
    ('freezeAuthority', getNullableDecoder<Address>(getAddressDecoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeMint2InstructionData(
      discriminator: map['discriminator']! as int,
      decimals: map['decimals']! as int,
      mintAuthority: map['mintAuthority']! as Address,
      freezeAuthority: map['freezeAuthority'] as Address?,
    ),
  );
}

Codec<InitializeMint2InstructionData, InitializeMint2InstructionData> getInitializeMint2InstructionDataCodec() {
  return combineCodec(getInitializeMint2InstructionDataEncoder(), getInitializeMint2InstructionDataDecoder());
}

/// Creates a [InitializeMint2] instruction.
Instruction getInitializeMint2Instruction({
  required Address programAddress,
  required Address mint,
  required int decimals,
  required Address mintAuthority,
  Address? freezeAuthority,
}) {
  final instructionData = InitializeMint2InstructionData(
      decimals: decimals,
      mintAuthority: mintAuthority,
      freezeAuthority: freezeAuthority ?? null,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeMint2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeMint2] instruction from raw instruction data.
InitializeMint2InstructionData parseInitializeMint2Instruction(Instruction instruction) {
  return getInitializeMint2InstructionDataDecoder().decode(instruction.data!);
}
