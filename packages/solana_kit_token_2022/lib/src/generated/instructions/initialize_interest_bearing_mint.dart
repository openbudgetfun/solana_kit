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

/// The discriminator field name: 'interestBearingMintDiscriminator'.
/// Offset: 1.

@immutable
class InitializeInterestBearingMintInstructionData {
  const InitializeInterestBearingMintInstructionData({
    this.discriminator = 33,
    this.interestBearingMintDiscriminator = 0,
    required this.rateAuthority,
    required this.rate,
  });

  final int discriminator;
  final int interestBearingMintDiscriminator;
  final Address? rateAuthority;
  final int rate;
}

Encoder<InitializeInterestBearingMintInstructionData> getInitializeInterestBearingMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('interestBearingMintDiscriminator', getU8Encoder()),
    ('rateAuthority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('rate', getI16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeInterestBearingMintInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'interestBearingMintDiscriminator': value.interestBearingMintDiscriminator,
      'rateAuthority': value.rateAuthority,
      'rate': value.rate,
    },
  );
}

Decoder<InitializeInterestBearingMintInstructionData> getInitializeInterestBearingMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('interestBearingMintDiscriminator', getU8Decoder()),
    ('rateAuthority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('rate', getI16Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeInterestBearingMintInstructionData(
      discriminator: map['discriminator']! as int,
      interestBearingMintDiscriminator: map['interestBearingMintDiscriminator']! as int,
      rateAuthority: map['rateAuthority'] as Address?,
      rate: map['rate']! as int,
    ),
  );
}

Codec<InitializeInterestBearingMintInstructionData, InitializeInterestBearingMintInstructionData> getInitializeInterestBearingMintInstructionDataCodec() {
  return combineCodec(getInitializeInterestBearingMintInstructionDataEncoder(), getInitializeInterestBearingMintInstructionDataDecoder());
}

/// Creates a [InitializeInterestBearingMint] instruction.
Instruction getInitializeInterestBearingMintInstruction({
  required Address programAddress,
  required Address mint,
  required Address? rateAuthority,
  required int rate,
}) {
  final instructionData = InitializeInterestBearingMintInstructionData(
      rateAuthority: rateAuthority,
      rate: rate,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeInterestBearingMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeInterestBearingMint] instruction from raw instruction data.
InitializeInterestBearingMintInstructionData parseInitializeInterestBearingMintInstruction(Instruction instruction) {
  return getInitializeInterestBearingMintInstructionDataDecoder().decode(instruction.data!);
}
