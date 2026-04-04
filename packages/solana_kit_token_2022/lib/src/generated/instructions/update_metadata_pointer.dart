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
class UpdateMetadataPointerInstructionData {
  const UpdateMetadataPointerInstructionData({
    this.discriminator = 39,
    this.metadataPointerDiscriminator = 1,
    required this.metadataAddress,
  });

  final int discriminator;
  final int metadataPointerDiscriminator;
  final Address? metadataAddress;
}

Encoder<UpdateMetadataPointerInstructionData> getUpdateMetadataPointerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('metadataPointerDiscriminator', getU8Encoder()),
    ('metadataAddress', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateMetadataPointerInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'metadataPointerDiscriminator': value.metadataPointerDiscriminator,
      'metadataAddress': value.metadataAddress,
    },
  );
}

Decoder<UpdateMetadataPointerInstructionData> getUpdateMetadataPointerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('metadataPointerDiscriminator', getU8Decoder()),
    ('metadataAddress', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateMetadataPointerInstructionData(
      discriminator: map['discriminator']! as int,
      metadataPointerDiscriminator: map['metadataPointerDiscriminator']! as int,
      metadataAddress: map['metadataAddress'] as Address?,
    ),
  );
}

Codec<UpdateMetadataPointerInstructionData, UpdateMetadataPointerInstructionData> getUpdateMetadataPointerInstructionDataCodec() {
  return combineCodec(getUpdateMetadataPointerInstructionDataEncoder(), getUpdateMetadataPointerInstructionDataDecoder());
}

/// Creates a [UpdateMetadataPointer] instruction.
Instruction getUpdateMetadataPointerInstruction({
  required Address programAddress,
  required Address mint,
  required Address metadataPointerAuthority,
  required Address? metadataAddress,
}) {
  final instructionData = UpdateMetadataPointerInstructionData(
      metadataAddress: metadataAddress,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: mint, role: AccountRole.writable),
    AccountMeta(address: metadataPointerAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateMetadataPointerInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateMetadataPointer] instruction from raw instruction data.
UpdateMetadataPointerInstructionData parseUpdateMetadataPointerInstruction(Instruction instruction) {
  return getUpdateMetadataPointerInstructionDataDecoder().decode(instruction.data!);
}
