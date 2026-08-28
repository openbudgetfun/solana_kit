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
class CloseAccountsInstructionData {
  const CloseAccountsInstructionData() : discriminator = 57;

  final int discriminator;
}

Encoder<CloseAccountsInstructionData> getCloseAccountsInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseAccountsInstructionData value) => <String, Object?>{
      'discriminator': 57,
    },
  );
}

Decoder<CloseAccountsInstructionData> getCloseAccountsInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'closeAccounts instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CloseAccountsInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(57),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CloseAccountsInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CloseAccountsInstructionData>(
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
      VariableSizeDecoder<CloseAccountsInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CloseAccountsInstructionData, CloseAccountsInstructionData>
getCloseAccountsInstructionDataCodec() {
  return combineCodec(
    getCloseAccountsInstructionDataEncoder(),
    getCloseAccountsInstructionDataDecoder(),
  );
}

/// Creates a [CloseAccounts] instruction.
Instruction getCloseAccountsInstruction({
  required Address programAddress,
  required Address metadata,
  required Address edition,
  required Address mint,
  required Address authority,
  required Address destination,
}) {
  final instructionData = CloseAccountsInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: edition, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: destination, role: AccountRole.writable),
    ],
    data: getCloseAccountsInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseAccounts] instruction from raw instruction data.
CloseAccountsInstructionData parseCloseAccountsInstruction(
  Instruction instruction,
) {
  return getCloseAccountsInstructionDataDecoder().decode(instruction.data!);
}
