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
class CloseAccountInstructionData {
  const CloseAccountInstructionData() : discriminator = 9;

  final int discriminator;
}

Encoder<CloseAccountInstructionData> getCloseAccountInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseAccountInstructionData value) => <String, Object?>{
      'discriminator': 9,
    },
  );
}

Decoder<CloseAccountInstructionData> getCloseAccountInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'closeAccount instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CloseAccountInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(9),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CloseAccountInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CloseAccountInstructionData>(
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
      VariableSizeDecoder<CloseAccountInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CloseAccountInstructionData, CloseAccountInstructionData>
getCloseAccountInstructionDataCodec() {
  return combineCodec(
    getCloseAccountInstructionDataEncoder(),
    getCloseAccountInstructionDataDecoder(),
  );
}

/// Creates a [CloseAccount] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getCloseAccountInstruction({
  required Address programAddress,
  required Address account,
  required Address destination,
  required Address owner,

  bool ownerIsSigner = true,
}) {
  final instructionData = CloseAccountInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: account, role: AccountRole.writable),
      AccountMeta(address: destination, role: AccountRole.writable),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getCloseAccountInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseAccount] instruction from raw instruction data.
CloseAccountInstructionData parseCloseAccountInstruction(
  Instruction instruction,
) {
  return getCloseAccountInstructionDataDecoder().decode(instruction.data!);
}
