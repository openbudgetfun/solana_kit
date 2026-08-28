// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MultisigCreateInstructionData {
  MultisigCreateInstructionData()
    : discriminator = Uint8List.fromList([
        0x7a,
        0x4d,
        0x50,
        0x9f,
        0x54,
        0x58,
        0x5a,
        0xc5,
      ]);

  final Uint8List discriminator;
}

Encoder<MultisigCreateInstructionData>
getMultisigCreateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MultisigCreateInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x7a,
        0x4d,
        0x50,
        0x9f,
        0x54,
        0x58,
        0x5a,
        0xc5,
      ]),
    },
  );
}

Decoder<MultisigCreateInstructionData>
getMultisigCreateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'multisigCreate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MultisigCreateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x7a, 0x4d, 0x50, 0x9f, 0x54, 0x58, 0x5a, 0xc5]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MultisigCreateInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MultisigCreateInstructionData>(
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
      VariableSizeDecoder<MultisigCreateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MultisigCreateInstructionData, MultisigCreateInstructionData>
getMultisigCreateInstructionDataCodec() {
  return combineCodec(
    getMultisigCreateInstructionDataEncoder(),
    getMultisigCreateInstructionDataDecoder(),
  );
}

/// Creates a [MultisigCreate] instruction.
Instruction getMultisigCreateInstruction({
  required Address programAddress,
  required Address null_,
}) {
  final instructionData = MultisigCreateInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: null_, role: AccountRole.readonly),
    ],
    data: getMultisigCreateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MultisigCreate] instruction from raw instruction data.
MultisigCreateInstructionData parseMultisigCreateInstruction(
  Instruction instruction,
) {
  return getMultisigCreateInstructionDataDecoder().decode(instruction.data!);
}
