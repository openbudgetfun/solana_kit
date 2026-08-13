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

/// The discriminator field name: 'metadataPointerDiscriminator'.
/// Offset: 1.

@immutable
class InitializeMetadataPointerInstructionData {
  const InitializeMetadataPointerInstructionData({
    this.discriminator = 39,
    this.metadataPointerDiscriminator = 0,
    required this.authority,
    required this.metadataAddress,
  });

  final int discriminator;
  final int metadataPointerDiscriminator;
  final Address? authority;
  final Address? metadataAddress;
}

Encoder<InitializeMetadataPointerInstructionData> getInitializeMetadataPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('metadataPointerDiscriminator', getU8Encoder()),
    ('authority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('metadataAddress', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMetadataPointerInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'metadataPointerDiscriminator': value.metadataPointerDiscriminator,
      'authority': value.authority,
      'metadataAddress': value.metadataAddress,
    },
  );
}

Decoder<InitializeMetadataPointerInstructionData> getInitializeMetadataPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('metadataPointerDiscriminator', getU8Decoder()),
    ('authority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
    ('metadataAddress', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeMetadataPointerInstructionData(
      discriminator: map['discriminator']! as int,
      metadataPointerDiscriminator: map['metadataPointerDiscriminator']! as int,
      authority: map['authority'] as Address?,
      metadataAddress: map['metadataAddress'] as Address?,
    ),
  );
}

Codec<InitializeMetadataPointerInstructionData, InitializeMetadataPointerInstructionData> getInitializeMetadataPointerInstructionDataCodec() {
  return combineCodec(getInitializeMetadataPointerInstructionDataEncoder(), getInitializeMetadataPointerInstructionDataDecoder());
}

/// Creates a [InitializeMetadataPointer] instruction.
Instruction getInitializeMetadataPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address? authority,
  required Address? metadataAddress,
}) {
  final instructionData = InitializeMetadataPointerInstructionData(
      authority: authority,
      metadataAddress: metadataAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeMetadataPointerInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeMetadataPointer] instruction from raw instruction data.
InitializeMetadataPointerInstructionData parseInitializeMetadataPointerInstruction(Instruction instruction) {
  return getInitializeMetadataPointerInstructionDataDecoder().decode(instruction.data!);
}
