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
class RemoveCreatorVerificationInstructionData {
  const RemoveCreatorVerificationInstructionData() : discriminator = 28;

  final int discriminator;
}

Encoder<RemoveCreatorVerificationInstructionData>
getRemoveCreatorVerificationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RemoveCreatorVerificationInstructionData value) => <String, Object?>{
      'discriminator': 28,
    },
  );
}

Decoder<RemoveCreatorVerificationInstructionData>
getRemoveCreatorVerificationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'removeCreatorVerification instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RemoveCreatorVerificationInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(28),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RemoveCreatorVerificationInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RemoveCreatorVerificationInstructionData>(
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
      VariableSizeDecoder<RemoveCreatorVerificationInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RemoveCreatorVerificationInstructionData,
  RemoveCreatorVerificationInstructionData
>
getRemoveCreatorVerificationInstructionDataCodec() {
  return combineCodec(
    getRemoveCreatorVerificationInstructionDataEncoder(),
    getRemoveCreatorVerificationInstructionDataDecoder(),
  );
}

/// Creates a [RemoveCreatorVerification] instruction.
Instruction getRemoveCreatorVerificationInstruction({
  required Address programAddress,
  required Address metadata,
  required Address creator,
}) {
  final instructionData = RemoveCreatorVerificationInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
    ],
    data: getRemoveCreatorVerificationInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RemoveCreatorVerification] instruction from raw instruction data.
RemoveCreatorVerificationInstructionData
parseRemoveCreatorVerificationInstruction(Instruction instruction) {
  return getRemoveCreatorVerificationInstructionDataDecoder().decode(
    instruction.data!,
  );
}
