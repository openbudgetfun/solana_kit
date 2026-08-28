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

import '../types/compression_proof.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class BurnCollectionV1InstructionData {
  const BurnCollectionV1InstructionData({
    required this.compressionProof,
  }) : discriminator = 13;

  final int discriminator;
  final CompressionProof? compressionProof;
}

Encoder<BurnCollectionV1InstructionData>
getBurnCollectionV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'compressionProof',
      getNullableEncoder<CompressionProof>(getCompressionProofEncoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnCollectionV1InstructionData value) => <String, Object?>{
      'discriminator': 13,
      'compressionProof': value.compressionProof,
    },
  );
}

Decoder<BurnCollectionV1InstructionData>
getBurnCollectionV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'compressionProof',
      getNullableDecoder<CompressionProof>(getCompressionProofDecoder()),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'burnCollectionV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BurnCollectionV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(13),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BurnCollectionV1InstructionData(
        compressionProof: map['compressionProof'] as CompressionProof?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BurnCollectionV1InstructionData>(
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
      VariableSizeDecoder<BurnCollectionV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BurnCollectionV1InstructionData, BurnCollectionV1InstructionData>
getBurnCollectionV1InstructionDataCodec() {
  return combineCodec(
    getBurnCollectionV1InstructionDataEncoder(),
    getBurnCollectionV1InstructionDataDecoder(),
  );
}

/// Creates a [BurnCollectionV1] instruction.
Instruction getBurnCollectionV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  Address? logWrapper,
  required CompressionProof? compressionProof,
}) {
  final instructionData = BurnCollectionV1InstructionData(
    compressionProof: compressionProof,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collection, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.writableSigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getBurnCollectionV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [BurnCollectionV1] instruction from raw instruction data.
BurnCollectionV1InstructionData parseBurnCollectionV1Instruction(
  Instruction instruction,
) {
  return getBurnCollectionV1InstructionDataDecoder().decode(instruction.data!);
}
