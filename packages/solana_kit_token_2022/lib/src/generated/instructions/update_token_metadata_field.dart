// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/token_metadata_field.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateTokenMetadataFieldInstructionData {
  UpdateTokenMetadataFieldInstructionData({
    Uint8List? discriminator,
    required this.field,
    required this.value,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([221, 233, 49, 45, 181, 202, 220, 200]);

  final Uint8List discriminator;
  final TokenMetadataField field;
  final String value;
}

Encoder<UpdateTokenMetadataFieldInstructionData> getUpdateTokenMetadataFieldInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('field', getTokenMetadataFieldEncoder()),
    ('value', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTokenMetadataFieldInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'field': value.field,
      'value': value.value,
    },
  );
}

Decoder<UpdateTokenMetadataFieldInstructionData> getUpdateTokenMetadataFieldInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('field', getTokenMetadataFieldDecoder()),
    ('value', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => UpdateTokenMetadataFieldInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      field: map['field']! as TokenMetadataField,
      value: map['value']! as String,
    ),
  );
}

Codec<UpdateTokenMetadataFieldInstructionData, UpdateTokenMetadataFieldInstructionData> getUpdateTokenMetadataFieldInstructionDataCodec() {
  return combineCodec(getUpdateTokenMetadataFieldInstructionDataEncoder(), getUpdateTokenMetadataFieldInstructionDataDecoder());
}

/// Creates a [UpdateTokenMetadataField] instruction.
Instruction getUpdateTokenMetadataFieldInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required TokenMetadataField field,
  required String value,
}) {
  final instructionData = UpdateTokenMetadataFieldInstructionData(
      field: field,
      value: value,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: metadata, role: AccountRole.writable),
    AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateTokenMetadataFieldInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateTokenMetadataField] instruction from raw instruction data.
UpdateTokenMetadataFieldInstructionData parseUpdateTokenMetadataFieldInstruction(Instruction instruction) {
  return getUpdateTokenMetadataFieldInstructionDataDecoder().decode(instruction.data!);
}
