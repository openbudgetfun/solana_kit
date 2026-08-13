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
class BatchInstructionData {
  const BatchInstructionData({
    this.discriminator = 255,
    required this.data,
  });

  final int discriminator;
  final List<Map<String, Object?>> data;
}

Encoder<BatchInstructionData> getBatchInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('data', getArrayEncoder(getStructEncoder([('numberOfAccounts', getU8Encoder()), ('instructionData', addEncoderSizePrefix(getBytesEncoder(), getU8Encoder()))]), size: RemainderArraySize())),
  ]);

  return transformEncoder(
    structEncoder,
    (BatchInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'data': value.data,
    },
  );
}

Decoder<BatchInstructionData> getBatchInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('data', getArrayDecoder(getStructDecoder([('numberOfAccounts', getU8Decoder()), ('instructionData', addDecoderSizePrefix(getBytesDecoder(), getU8Decoder()))]), size: RemainderArraySize())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => BatchInstructionData(
      discriminator: map['discriminator']! as int,
      data: map['data']! as List<Map<String, Object?>>,
    ),
  );
}

Codec<BatchInstructionData, BatchInstructionData> getBatchInstructionDataCodec() {
  return combineCodec(getBatchInstructionDataEncoder(), getBatchInstructionDataDecoder());
}

/// Creates a [Batch] instruction.
Instruction getBatchInstruction({
  required Address programAddress,

  required List<Map<String, Object?>> data,
}) {
  final instructionData = BatchInstructionData(
      data: data,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [

    ],
    data: getBatchInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Batch] instruction from raw instruction data.
BatchInstructionData parseBatchInstruction(Instruction instruction) {
  return getBatchInstructionDataDecoder().decode(instruction.data!);
}
