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
class InitializeImmutableOwnerInstructionData {
  const InitializeImmutableOwnerInstructionData() : discriminator = 22;

  final int discriminator;
}

Encoder<InitializeImmutableOwnerInstructionData>
getInitializeImmutableOwnerInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeImmutableOwnerInstructionData value) => <String, Object?>{
      'discriminator': 22,
    },
  );
}

Decoder<InitializeImmutableOwnerInstructionData>
getInitializeImmutableOwnerInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeImmutableOwner instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeImmutableOwnerInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(22),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeImmutableOwnerInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeImmutableOwnerInstructionData>(
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
      VariableSizeDecoder<InitializeImmutableOwnerInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeImmutableOwnerInstructionData,
  InitializeImmutableOwnerInstructionData
>
getInitializeImmutableOwnerInstructionDataCodec() {
  return combineCodec(
    getInitializeImmutableOwnerInstructionDataEncoder(),
    getInitializeImmutableOwnerInstructionDataDecoder(),
  );
}

/// Creates a [InitializeImmutableOwner] instruction.
Instruction getInitializeImmutableOwnerInstruction({
  required Address programAddress,
  required Address account,
}) {
  final instructionData = InitializeImmutableOwnerInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: account, role: AccountRole.writable),
    ],
    data: getInitializeImmutableOwnerInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeImmutableOwner] instruction from raw instruction data.
InitializeImmutableOwnerInstructionData
parseInitializeImmutableOwnerInstruction(Instruction instruction) {
  return getInitializeImmutableOwnerInstructionDataDecoder().decode(
    instruction.data!,
  );
}
