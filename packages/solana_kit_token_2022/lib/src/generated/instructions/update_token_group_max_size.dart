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
class UpdateTokenGroupMaxSizeInstructionData {
  UpdateTokenGroupMaxSizeInstructionData({
    required this.maxSize,
  }) : discriminator = Uint8List.fromList([
         0x6c,
         0x25,
         0xab,
         0x8f,
         0xf8,
         0x1e,
         0x12,
         0x6e,
       ]);

  final Uint8List discriminator;
  final BigInt maxSize;
}

Encoder<UpdateTokenGroupMaxSizeInstructionData>
getUpdateTokenGroupMaxSizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('maxSize', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTokenGroupMaxSizeInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x6c,
        0x25,
        0xab,
        0x8f,
        0xf8,
        0x1e,
        0x12,
        0x6e,
      ]),
      'maxSize': value.maxSize,
    },
  );
}

Decoder<UpdateTokenGroupMaxSizeInstructionData>
getUpdateTokenGroupMaxSizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('maxSize', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateTokenGroupMaxSize instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateTokenGroupMaxSizeInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x6c, 0x25, 0xab, 0x8f, 0xf8, 0x1e, 0x12, 0x6e]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateTokenGroupMaxSizeInstructionData(
        maxSize: map['maxSize']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateTokenGroupMaxSizeInstructionData>(
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
      VariableSizeDecoder<UpdateTokenGroupMaxSizeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateTokenGroupMaxSizeInstructionData,
  UpdateTokenGroupMaxSizeInstructionData
>
getUpdateTokenGroupMaxSizeInstructionDataCodec() {
  return combineCodec(
    getUpdateTokenGroupMaxSizeInstructionDataEncoder(),
    getUpdateTokenGroupMaxSizeInstructionDataDecoder(),
  );
}

/// Creates a [UpdateTokenGroupMaxSize] instruction.
Instruction getUpdateTokenGroupMaxSizeInstruction({
  required Address programAddress,
  required Address group,
  required Address updateAuthority,
  required BigInt maxSize,
}) {
  final instructionData = UpdateTokenGroupMaxSizeInstructionData(
    maxSize: maxSize,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateTokenGroupMaxSizeInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateTokenGroupMaxSize] instruction from raw instruction data.
UpdateTokenGroupMaxSizeInstructionData parseUpdateTokenGroupMaxSizeInstruction(
  Instruction instruction,
) {
  return getUpdateTokenGroupMaxSizeInstructionDataDecoder().decode(
    instruction.data!,
  );
}
