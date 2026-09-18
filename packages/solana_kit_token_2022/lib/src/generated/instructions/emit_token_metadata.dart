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
class EmitTokenMetadataInstructionData {
  EmitTokenMetadataInstructionData({
    required this.start,
    required this.end,
  }) : discriminator = Uint8List.fromList([
         0xfa,
         0xa6,
         0xb4,
         0xfa,
         0x0d,
         0x0c,
         0xb8,
         0x46,
       ]);

  final Uint8List discriminator;
  final BigInt? start;
  final BigInt? end;
}

Encoder<EmitTokenMetadataInstructionData>
getEmitTokenMetadataInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    (
      'start',
      getNullableEncoder<BigInt>(
        transformEncoder(getU64Encoder(), (BigInt value) => value),
      ),
    ),
    (
      'end',
      getNullableEncoder<BigInt>(
        transformEncoder(getU64Encoder(), (BigInt value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (EmitTokenMetadataInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xfa,
        0xa6,
        0xb4,
        0xfa,
        0x0d,
        0x0c,
        0xb8,
        0x46,
      ]),
      'start': value.start,
      'end': value.end,
    },
  );
}

Decoder<EmitTokenMetadataInstructionData>
getEmitTokenMetadataInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('start', getNullableDecoder<BigInt>(getU64Decoder())),
    ('end', getNullableDecoder<BigInt>(getU64Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'emitTokenMetadata instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EmitTokenMetadataInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xfa, 0xa6, 0xb4, 0xfa, 0x0d, 0x0c, 0xb8, 0x46]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      EmitTokenMetadataInstructionData(
        start: map['start'] as BigInt?,
        end: map['end'] as BigInt?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EmitTokenMetadataInstructionData>(
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
      VariableSizeDecoder<EmitTokenMetadataInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<EmitTokenMetadataInstructionData, EmitTokenMetadataInstructionData>
getEmitTokenMetadataInstructionDataCodec() {
  return combineCodec(
    getEmitTokenMetadataInstructionDataEncoder(),
    getEmitTokenMetadataInstructionDataDecoder(),
  );
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
EmitTokenMetadataInstructionData parseEmitTokenMetadataInstruction(
  Instruction instruction,
) {
  return getEmitTokenMetadataInstructionDataDecoder().decode(instruction.data!);
}
