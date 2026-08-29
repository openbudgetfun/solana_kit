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
class FreezeDelegatedAccountInstructionData {
  const FreezeDelegatedAccountInstructionData() : discriminator = 26;

  final int discriminator;
}

Encoder<FreezeDelegatedAccountInstructionData>
getFreezeDelegatedAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (FreezeDelegatedAccountInstructionData value) => <String, Object?>{
      'discriminator': 26,
    },
  );
}

Decoder<FreezeDelegatedAccountInstructionData>
getFreezeDelegatedAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'freezeDelegatedAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (FreezeDelegatedAccountInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(26),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      FreezeDelegatedAccountInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<FreezeDelegatedAccountInstructionData>(
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
      VariableSizeDecoder<FreezeDelegatedAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  FreezeDelegatedAccountInstructionData,
  FreezeDelegatedAccountInstructionData
>
getFreezeDelegatedAccountInstructionDataCodec() {
  return combineCodec(
    getFreezeDelegatedAccountInstructionDataEncoder(),
    getFreezeDelegatedAccountInstructionDataDecoder(),
  );
}

/// Creates a [FreezeDelegatedAccount] instruction.
Instruction getFreezeDelegatedAccountInstruction({
  required Address programAddress,
  required Address delegate,
  required Address tokenAccount,
  required Address edition,
  required Address mint,
  required Address tokenProgram,
}) {
  final instructionData = FreezeDelegatedAccountInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: delegate, role: AccountRole.writableSigner),
      AccountMeta(address: tokenAccount, role: AccountRole.writable),
      AccountMeta(address: edition, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getFreezeDelegatedAccountInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [FreezeDelegatedAccount] instruction from raw instruction data.
FreezeDelegatedAccountInstructionData parseFreezeDelegatedAccountInstruction(
  Instruction instruction,
) {
  return getFreezeDelegatedAccountInstructionDataDecoder().decode(
    instruction.data!,
  );
}
