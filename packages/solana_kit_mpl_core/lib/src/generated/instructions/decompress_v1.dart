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
class DecompressV1InstructionData {
  const DecompressV1InstructionData({
    required this.compressionProof,
  }) : discriminator = 18;

  final int discriminator;
  final CompressionProof compressionProof;
}

Encoder<DecompressV1InstructionData> getDecompressV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('compressionProof', getCompressionProofEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DecompressV1InstructionData value) => <String, Object?>{
      'discriminator': 18,
      'compressionProof': value.compressionProof,
    },
  );
}

Decoder<DecompressV1InstructionData> getDecompressV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('compressionProof', getCompressionProofDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'decompressV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DecompressV1InstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(18),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DecompressV1InstructionData(
        compressionProof: map['compressionProof']! as CompressionProof,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DecompressV1InstructionData>(
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
      VariableSizeDecoder<DecompressV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<DecompressV1InstructionData, DecompressV1InstructionData>
getDecompressV1InstructionDataCodec() {
  return combineCodec(
    getDecompressV1InstructionDataEncoder(),
    getDecompressV1InstructionDataDecoder(),
  );
}

/// Creates a [DecompressV1] instruction.
Instruction getDecompressV1Instruction({
  required Address programAddress,
  required Address asset,
  Address? collection,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  Address? logWrapper,
  required CompressionProof compressionProof,
}) {
  final instructionData = DecompressV1InstructionData(
    compressionProof: compressionProof,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: asset, role: AccountRole.writable),
      if (collection != null)
        AccountMeta(address: collection, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getDecompressV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [DecompressV1] instruction from raw instruction data.
DecompressV1InstructionData parseDecompressV1Instruction(
  Instruction instruction,
) {
  return getDecompressV1InstructionDataDecoder().decode(instruction.data!);
}
