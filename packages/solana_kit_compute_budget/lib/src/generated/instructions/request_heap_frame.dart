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
class RequestHeapFrameInstructionData {
  const RequestHeapFrameInstructionData({
    this.discriminator = 1,
    required this.bytes,
  });

  final int discriminator;
  final int bytes;
}

Encoder<RequestHeapFrameInstructionData>
getRequestHeapFrameInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('bytes', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RequestHeapFrameInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'bytes': value.bytes,
    },
  );
}

Decoder<RequestHeapFrameInstructionData>
getRequestHeapFrameInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('bytes', getU32Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        RequestHeapFrameInstructionData(
          discriminator: map['discriminator']! as int,
          bytes: map['bytes']! as int,
        ),
  );
}

Codec<RequestHeapFrameInstructionData, RequestHeapFrameInstructionData>
getRequestHeapFrameInstructionDataCodec() {
  return combineCodec(
    getRequestHeapFrameInstructionDataEncoder(),
    getRequestHeapFrameInstructionDataDecoder(),
  );
}

/// Creates a [RequestHeapFrame] instruction.
Instruction getRequestHeapFrameInstruction({
  required Address programAddress,

  required int bytes,
}) {
  final instructionData = RequestHeapFrameInstructionData(
    bytes: bytes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [],
    data: getRequestHeapFrameInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [RequestHeapFrame] instruction from raw instruction data.
RequestHeapFrameInstructionData parseRequestHeapFrameInstruction(
  Instruction instruction,
) {
  return getRequestHeapFrameInstructionDataDecoder().decode(instruction.data!);
}
