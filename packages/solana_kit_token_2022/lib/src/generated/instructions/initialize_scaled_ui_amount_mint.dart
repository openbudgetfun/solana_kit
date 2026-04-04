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

/// The discriminator field name: 'scaledUiAmountMintDiscriminator'.
/// Offset: 1.

@immutable
class InitializeScaledUiAmountMintInstructionData {
  const InitializeScaledUiAmountMintInstructionData({
    this.discriminator = 43,
    this.scaledUiAmountMintDiscriminator = 0,
    required this.authority,
    required this.multiplier,
  });

  final int discriminator;
  final int scaledUiAmountMintDiscriminator;
  final Address? authority;
  final double multiplier;
}

Encoder<InitializeScaledUiAmountMintInstructionData> getInitializeScaledUiAmountMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('scaledUiAmountMintDiscriminator', getU8Encoder()),
    ('authority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('multiplier', getF64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeScaledUiAmountMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'scaledUiAmountMintDiscriminator': value.scaledUiAmountMintDiscriminator,
      'authority': value.authority,
      'multiplier': value.multiplier,
    },
  );
}

Decoder<InitializeScaledUiAmountMintInstructionData> getInitializeScaledUiAmountMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('scaledUiAmountMintDiscriminator', getU8Decoder()),
    ('authority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('multiplier', getF64Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeScaledUiAmountMintInstructionData(
      discriminator: map['discriminator']! as int,
      scaledUiAmountMintDiscriminator: map['scaledUiAmountMintDiscriminator']! as int,
      authority: map['authority'] as Address?,
      multiplier: map['multiplier']! as double,
    ),
  );
}

Codec<InitializeScaledUiAmountMintInstructionData, InitializeScaledUiAmountMintInstructionData> getInitializeScaledUiAmountMintInstructionDataCodec() {
  return combineCodec(getInitializeScaledUiAmountMintInstructionDataEncoder(), getInitializeScaledUiAmountMintInstructionDataDecoder());
}

/// Creates a [InitializeScaledUiAmountMint] instruction.
Instruction getInitializeScaledUiAmountMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required double multiplier,
}) {
  final instructionData = InitializeScaledUiAmountMintInstructionData(
      authority: authority,
      multiplier: multiplier,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeScaledUiAmountMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeScaledUiAmountMint] instruction from raw instruction data.
InitializeScaledUiAmountMintInstructionData parseInitializeScaledUiAmountMintInstruction(Instruction instruction) {
  return getInitializeScaledUiAmountMintInstructionDataDecoder().decode(instruction.data!);
}
