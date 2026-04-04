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

/// The discriminator field name: 'pausableDiscriminator'.
/// Offset: 1.

@immutable
class InitializePausableConfigInstructionData {
  const InitializePausableConfigInstructionData({
    this.discriminator = 44,
    this.pausableDiscriminator = 0,
    required this.authority,
  });

  final int discriminator;
  final int pausableDiscriminator;
  final Address? authority;
}

Encoder<InitializePausableConfigInstructionData> getInitializePausableConfigInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('pausableDiscriminator', getU8Encoder()),
    ('authority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializePausableConfigInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'pausableDiscriminator': value.pausableDiscriminator,
      'authority': value.authority,
    },
  );
}

Decoder<InitializePausableConfigInstructionData> getInitializePausableConfigInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('pausableDiscriminator', getU8Decoder()),
    ('authority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializePausableConfigInstructionData(
      discriminator: map['discriminator']! as int,
      pausableDiscriminator: map['pausableDiscriminator']! as int,
      authority: map['authority'] as Address?,
    ),
  );
}

Codec<InitializePausableConfigInstructionData, InitializePausableConfigInstructionData> getInitializePausableConfigInstructionDataCodec() {
  return combineCodec(getInitializePausableConfigInstructionDataEncoder(), getInitializePausableConfigInstructionDataDecoder());
}

/// Creates a [InitializePausableConfig] instruction.
Instruction getInitializePausableConfigInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
}) {
  final instructionData = InitializePausableConfigInstructionData(
      authority: authority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializePausableConfigInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializePausableConfig] instruction from raw instruction data.
InitializePausableConfigInstructionData parseInitializePausableConfigInstruction(Instruction instruction) {
  return getInitializePausableConfigInstructionDataDecoder().decode(instruction.data!);
}
