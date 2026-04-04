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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class RemoveTokenMetadataKeyInstructionData {
  RemoveTokenMetadataKeyInstructionData({
    Uint8List? discriminator,
    required this.idempotent,
    required this.key,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([234, 18, 32, 56, 89, 141, 37, 181]);

  final Uint8List discriminator;
  final bool idempotent;
  final String key;
}

Encoder<RemoveTokenMetadataKeyInstructionData> getRemoveTokenMetadataKeyInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('idempotent', getBooleanEncoder()),
    ('key', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (RemoveTokenMetadataKeyInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'idempotent': value.idempotent,
      'key': value.key,
    },
  );
}

Decoder<RemoveTokenMetadataKeyInstructionData> getRemoveTokenMetadataKeyInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('idempotent', getBooleanDecoder()),
    ('key', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => RemoveTokenMetadataKeyInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      idempotent: map['idempotent']! as bool,
      key: map['key']! as String,
    ),
  );
}

Codec<RemoveTokenMetadataKeyInstructionData, RemoveTokenMetadataKeyInstructionData> getRemoveTokenMetadataKeyInstructionDataCodec() {
  return combineCodec(getRemoveTokenMetadataKeyInstructionDataEncoder(), getRemoveTokenMetadataKeyInstructionDataDecoder());
}

/// Creates a [RemoveTokenMetadataKey] instruction.
Instruction getRemoveTokenMetadataKeyInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  bool? idempotent,
  required String key,
}) {
  final instructionData = RemoveTokenMetadataKeyInstructionData(
      idempotent: idempotent ?? false,
      key: key,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: metadata, role: AccountRole.writable),
    AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getRemoveTokenMetadataKeyInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RemoveTokenMetadataKey] instruction from raw instruction data.
RemoveTokenMetadataKeyInstructionData parseRemoveTokenMetadataKeyInstruction(Instruction instruction) {
  return getRemoveTokenMetadataKeyInstructionDataDecoder().decode(instruction.data!);
}
