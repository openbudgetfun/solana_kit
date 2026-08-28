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
class BurnV1InstructionData {
  const BurnV1InstructionData({
    required this.compressionProof,
  }) : discriminator = 12;

  final int discriminator;
  final CompressionProof? compressionProof;
}

Encoder<BurnV1InstructionData> getBurnV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'compressionProof',
      getNullableEncoder<CompressionProof>(getCompressionProofEncoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnV1InstructionData value) => <String, Object?>{
      'discriminator': 12,
      'compressionProof': value.compressionProof,
    },
  );
}

Decoder<BurnV1InstructionData> getBurnV1InstructionDataDecoder() {
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
        'codecDescription': 'burnV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BurnV1InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(12),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BurnV1InstructionData(
        compressionProof: map['compressionProof'] as CompressionProof?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BurnV1InstructionData>(
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
      VariableSizeDecoder<BurnV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BurnV1InstructionData, BurnV1InstructionData>
getBurnV1InstructionDataCodec() {
  return combineCodec(
    getBurnV1InstructionDataEncoder(),
    getBurnV1InstructionDataDecoder(),
  );
}

/// Creates a [BurnV1] instruction.
Instruction getBurnV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  Address? systemProgram,
  Address? logWrapper,
  required CompressionProof? compressionProof,
}) {
  final instructionData = BurnV1InstructionData(
    compressionProof: compressionProof,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: asset, role: AccountRole.writable),
      if (collection != null)
        AccountMeta(address: collection, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (systemProgram != null)
        AccountMeta(address: systemProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getBurnV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [BurnV1] instruction from raw instruction data.
BurnV1InstructionData parseBurnV1Instruction(Instruction instruction) {
  return getBurnV1InstructionDataDecoder().decode(instruction.data!);
}
