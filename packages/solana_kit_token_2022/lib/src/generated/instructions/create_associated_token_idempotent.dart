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
class CreateAssociatedTokenIdempotentInstructionData {
  const CreateAssociatedTokenIdempotentInstructionData() : discriminator = 1;

  final int discriminator;
}

Encoder<CreateAssociatedTokenIdempotentInstructionData>
getCreateAssociatedTokenIdempotentInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAssociatedTokenIdempotentInstructionData value) => <String, Object?>{
      'discriminator': 1,
    },
  );
}

Decoder<CreateAssociatedTokenIdempotentInstructionData>
getCreateAssociatedTokenIdempotentInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'createAssociatedTokenIdempotent instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateAssociatedTokenIdempotentInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateAssociatedTokenIdempotentInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateAssociatedTokenIdempotentInstructionData>(
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
      VariableSizeDecoder<CreateAssociatedTokenIdempotentInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  CreateAssociatedTokenIdempotentInstructionData,
  CreateAssociatedTokenIdempotentInstructionData
>
getCreateAssociatedTokenIdempotentInstructionDataCodec() {
  return combineCodec(
    getCreateAssociatedTokenIdempotentInstructionDataEncoder(),
    getCreateAssociatedTokenIdempotentInstructionDataDecoder(),
  );
}

/// Creates a [CreateAssociatedTokenIdempotent] instruction.
Instruction getCreateAssociatedTokenIdempotentInstruction({
  required Address programAddress,
  required Address payer,
  required Address ata,
  required Address owner,
  required Address mint,
  required Address systemProgram,
  required Address tokenProgram,
}) {
  final instructionData = CreateAssociatedTokenIdempotentInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: ata, role: AccountRole.writable),
      AccountMeta(address: owner, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getCreateAssociatedTokenIdempotentInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateAssociatedTokenIdempotent] instruction from raw instruction data.
CreateAssociatedTokenIdempotentInstructionData
parseCreateAssociatedTokenIdempotentInstruction(Instruction instruction) {
  return getCreateAssociatedTokenIdempotentInstructionDataDecoder().decode(
    instruction.data!,
  );
}
