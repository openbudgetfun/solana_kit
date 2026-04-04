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
class EmitTokenMetadataInstructionData {
  EmitTokenMetadataInstructionData({
    Uint8List? discriminator,
    required this.start,
    required this.end,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([250, 166, 180, 250, 13, 12, 184, 70]);

  final Uint8List discriminator;
  final BigInt? start;
  final BigInt? end;
}

Encoder<EmitTokenMetadataInstructionData> getEmitTokenMetadataInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('start', getNullableEncoder<BigInt>(getU64Encoder())),
    ('end', getNullableEncoder<BigInt>(getU64Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (EmitTokenMetadataInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'start': value.start,
      'end': value.end,
    },
  );
}

Decoder<EmitTokenMetadataInstructionData> getEmitTokenMetadataInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('start', getNullableDecoder<BigInt>(getU64Decoder())),
    ('end', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => EmitTokenMetadataInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      start: map['start'] as BigInt?,
      end: map['end'] as BigInt?,
    ),
  );
}

Codec<EmitTokenMetadataInstructionData, EmitTokenMetadataInstructionData> getEmitTokenMetadataInstructionDataCodec() {
  return combineCodec(getEmitTokenMetadataInstructionDataEncoder(), getEmitTokenMetadataInstructionDataDecoder());
}

/// Creates a [EmitTokenMetadata] instruction.
Instruction getEmitTokenMetadataInstruction({
  required Address programAddress,
  required Address metadata,
  BigInt? start,
  BigInt? end,
}) {
  final instructionData = EmitTokenMetadataInstructionData(
      start: start ?? null,
      end: end ?? null,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: metadata, role: AccountRole.readonly),
    ],
    data: getEmitTokenMetadataInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [EmitTokenMetadata] instruction from raw instruction data.
EmitTokenMetadataInstructionData parseEmitTokenMetadataInstruction(Instruction instruction) {
  return getEmitTokenMetadataInstructionDataDecoder().decode(instruction.data!);
}
