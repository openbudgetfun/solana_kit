// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class BatchInstructionData {
  const BatchInstructionData({
    required this.data,
  }) : discriminator = 255;

  final int discriminator;
  final List<Map<String, Object?>> data;
}

Encoder<BatchInstructionData> getBatchInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'data',
      getArrayEncoder(
        transformEncoder(
          getStructEncoder([
            ('numberOfAccounts', getU8Encoder()),
            (
              'instructionData',
              addEncoderSizePrefix(getBytesEncoder(), getU8Encoder()),
            ),
          ]),
          (Map<String, Object?> value) => value,
        ),
        size: RemainderArraySize(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (BatchInstructionData value) => <String, Object?>{
      'discriminator': 255,
      'data': value.data,
    },
  );
}

Decoder<BatchInstructionData> getBatchInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'data',
      getArrayDecoder(
        getStructDecoder([
          ('numberOfAccounts', getU8Decoder()),
          (
            'instructionData',
            addDecoderSizePrefix(getBytesDecoder(), getU8Decoder()),
          ),
        ]),
        size: RemainderArraySize(),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'batch instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BatchInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(255),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BatchInstructionData(
        data: map['data']! as List<Map<String, Object?>>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BatchInstructionData>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    VariableSizeDecoder<Map<String, Object?>>() =>
      VariableSizeDecoder<BatchInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BatchInstructionData, BatchInstructionData>
getBatchInstructionDataCodec() {
  return combineCodec(
    getBatchInstructionDataEncoder(),
    getBatchInstructionDataDecoder(),
  );
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
    accounts: [],
    data: getBatchInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Batch] instruction from raw instruction data.
BatchInstructionData parseBatchInstruction(Instruction instruction) {
  return getBatchInstructionDataDecoder().decode(instruction.data!);
}
