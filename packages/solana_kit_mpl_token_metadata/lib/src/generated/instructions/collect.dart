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
class CollectInstructionData {
  const CollectInstructionData() : discriminator = 54;

  final int discriminator;
}

Encoder<CollectInstructionData> getCollectInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CollectInstructionData value) => <String, Object?>{
      'discriminator': 54,
    },
  );
}

Decoder<CollectInstructionData> getCollectInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'collect instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CollectInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(54),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CollectInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CollectInstructionData>(
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
      VariableSizeDecoder<CollectInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CollectInstructionData, CollectInstructionData>
getCollectInstructionDataCodec() {
  return combineCodec(
    getCollectInstructionDataEncoder(),
    getCollectInstructionDataDecoder(),
  );
}

/// Creates a [Collect] instruction.
Instruction getCollectInstruction({
  required Address programAddress,
  required Address authority,
  required Address recipient,
}) {
  final instructionData = CollectInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: recipient, role: AccountRole.readonly),
    ],
    data: getCollectInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Collect] instruction from raw instruction data.
CollectInstructionData parseCollectInstruction(Instruction instruction) {
  return getCollectInstructionDataDecoder().decode(instruction.data!);
}
