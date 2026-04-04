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

/// The discriminator field name: 'confidentialTransferFeeDiscriminator'.
/// Offset: 1.

@immutable
class InitializeConfidentialTransferFeeInstructionData {
  const InitializeConfidentialTransferFeeInstructionData({
    this.discriminator = 37,
    this.confidentialTransferFeeDiscriminator = 0,
    required this.authority,
    required this.withdrawWithheldAuthorityElGamalPubkey,
  });

  final int discriminator;
  final int confidentialTransferFeeDiscriminator;
  final Address? authority;
  final Address? withdrawWithheldAuthorityElGamalPubkey;
}

Encoder<InitializeConfidentialTransferFeeInstructionData> getInitializeConfidentialTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialTransferFeeDiscriminator', getU8Encoder()),
    ('authority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('withdrawWithheldAuthorityElGamalPubkey', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeConfidentialTransferFeeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'confidentialTransferFeeDiscriminator': value.confidentialTransferFeeDiscriminator,
      'authority': value.authority,
      'withdrawWithheldAuthorityElGamalPubkey': value.withdrawWithheldAuthorityElGamalPubkey,
    },
  );
}

Decoder<InitializeConfidentialTransferFeeInstructionData> getInitializeConfidentialTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialTransferFeeDiscriminator', getU8Decoder()),
    ('authority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('withdrawWithheldAuthorityElGamalPubkey', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeConfidentialTransferFeeInstructionData(
      discriminator: map['discriminator']! as int,
      confidentialTransferFeeDiscriminator: map['confidentialTransferFeeDiscriminator']! as int,
      authority: map['authority'] as Address?,
      withdrawWithheldAuthorityElGamalPubkey: map['withdrawWithheldAuthorityElGamalPubkey'] as Address?,
    ),
  );
}

Codec<InitializeConfidentialTransferFeeInstructionData, InitializeConfidentialTransferFeeInstructionData> getInitializeConfidentialTransferFeeInstructionDataCodec() {
  return combineCodec(getInitializeConfidentialTransferFeeInstructionDataEncoder(), getInitializeConfidentialTransferFeeInstructionDataDecoder());
}

/// Creates a [InitializeConfidentialTransferFee] instruction.
Instruction getInitializeConfidentialTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required Address? withdrawWithheldAuthorityElGamalPubkey,
}) {
  final instructionData = InitializeConfidentialTransferFeeInstructionData(
      authority: authority,
      withdrawWithheldAuthorityElGamalPubkey: withdrawWithheldAuthorityElGamalPubkey,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeConfidentialTransferFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeConfidentialTransferFee] instruction from raw instruction data.
InitializeConfidentialTransferFeeInstructionData parseInitializeConfidentialTransferFeeInstruction(Instruction instruction) {
  return getInitializeConfidentialTransferFeeInstructionDataDecoder().decode(instruction.data!);
}
