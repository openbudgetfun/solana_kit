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
class ThawDelegatedAccountInstructionData {
  const ThawDelegatedAccountInstructionData() : discriminator = 27;

  final int discriminator;
}

Encoder<ThawDelegatedAccountInstructionData>
getThawDelegatedAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ThawDelegatedAccountInstructionData value) => <String, Object?>{
      'discriminator': 27,
    },
  );
}

Decoder<ThawDelegatedAccountInstructionData>
getThawDelegatedAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'thawDelegatedAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ThawDelegatedAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(27),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ThawDelegatedAccountInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ThawDelegatedAccountInstructionData>(
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
      VariableSizeDecoder<ThawDelegatedAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ThawDelegatedAccountInstructionData, ThawDelegatedAccountInstructionData>
getThawDelegatedAccountInstructionDataCodec() {
  return combineCodec(
    getThawDelegatedAccountInstructionDataEncoder(),
    getThawDelegatedAccountInstructionDataDecoder(),
  );
}

/// Creates a [ThawDelegatedAccount] instruction.
Instruction getThawDelegatedAccountInstruction({
  required Address programAddress,
  required Address delegate,
  required Address tokenAccount,
  required Address edition,
  required Address mint,
  required Address tokenProgram,
}) {
  final instructionData = ThawDelegatedAccountInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: delegate, role: AccountRole.writableSigner),
      AccountMeta(address: tokenAccount, role: AccountRole.writable),
      AccountMeta(address: edition, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getThawDelegatedAccountInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ThawDelegatedAccount] instruction from raw instruction data.
ThawDelegatedAccountInstructionData parseThawDelegatedAccountInstruction(
  Instruction instruction,
) {
  return getThawDelegatedAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
