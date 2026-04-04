// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateTokenMetadataUpdateAuthorityInstructionData {
  UpdateTokenMetadataUpdateAuthorityInstructionData({
    Uint8List? discriminator,
    required this.newUpdateAuthority,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([215, 228, 166, 228, 84, 100, 86, 123]);

  final Uint8List discriminator;
  final Address? newUpdateAuthority;
}

Encoder<UpdateTokenMetadataUpdateAuthorityInstructionData> getUpdateTokenMetadataUpdateAuthorityInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('newUpdateAuthority', getNullableEncoder<Address>(getAddressEncoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTokenMetadataUpdateAuthorityInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'newUpdateAuthority': value.newUpdateAuthority,
    },
  );
}

Decoder<UpdateTokenMetadataUpdateAuthorityInstructionData> getUpdateTokenMetadataUpdateAuthorityInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('newUpdateAuthority', getNullableDecoder<Address>(getAddressDecoder(), hasPrefix: false, noneValue: const ZeroesNoneValue())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateTokenMetadataUpdateAuthorityInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      newUpdateAuthority: map['newUpdateAuthority'] as Address?,
    ),
  );
}

Codec<UpdateTokenMetadataUpdateAuthorityInstructionData, UpdateTokenMetadataUpdateAuthorityInstructionData> getUpdateTokenMetadataUpdateAuthorityInstructionDataCodec() {
  return combineCodec(getUpdateTokenMetadataUpdateAuthorityInstructionDataEncoder(), getUpdateTokenMetadataUpdateAuthorityInstructionDataDecoder());
}

/// Creates a [UpdateTokenMetadataUpdateAuthority] instruction.
Instruction getUpdateTokenMetadataUpdateAuthorityInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required Address? newUpdateAuthority,
}) {
  final instructionData = UpdateTokenMetadataUpdateAuthorityInstructionData(
      newUpdateAuthority: newUpdateAuthority,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: metadata, role: AccountRole.writable),
    AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateTokenMetadataUpdateAuthorityInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateTokenMetadataUpdateAuthority] instruction from raw instruction data.
UpdateTokenMetadataUpdateAuthorityInstructionData parseUpdateTokenMetadataUpdateAuthorityInstruction(Instruction instruction) {
  return getUpdateTokenMetadataUpdateAuthorityInstructionDataDecoder().decode(instruction.data!);
}
