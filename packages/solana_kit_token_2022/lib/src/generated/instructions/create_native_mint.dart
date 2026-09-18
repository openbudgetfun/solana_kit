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
class CreateNativeMintInstructionData {
  const CreateNativeMintInstructionData() : discriminator = 31;

  final int discriminator;
}

Encoder<CreateNativeMintInstructionData>
getCreateNativeMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateNativeMintInstructionData value) => <String, Object?>{
      'discriminator': 31,
    },
  );
}

Decoder<CreateNativeMintInstructionData>
getCreateNativeMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createNativeMint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateNativeMintInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(31),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateNativeMintInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateNativeMintInstructionData>(
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
      VariableSizeDecoder<CreateNativeMintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateNativeMintInstructionData, CreateNativeMintInstructionData>
getCreateNativeMintInstructionDataCodec() {
  return combineCodec(
    getCreateNativeMintInstructionDataEncoder(),
    getCreateNativeMintInstructionDataDecoder(),
  );
}

/// Creates a [CreateNativeMint] instruction.
Instruction getCreateNativeMintInstruction({
  required Address programAddress,
  required Address payer,
  required Address nativeMint,
  required Address systemProgram,
}) {
  final instructionData = CreateNativeMintInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: nativeMint, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateNativeMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateNativeMint] instruction from raw instruction data.
CreateNativeMintInstructionData parseCreateNativeMintInstruction(
  Instruction instruction,
) {
  return getCreateNativeMintInstructionDataDecoder().decode(instruction.data!);
}
