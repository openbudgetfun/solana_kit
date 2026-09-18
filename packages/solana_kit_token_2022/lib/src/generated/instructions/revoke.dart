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
class RevokeInstructionData {
  const RevokeInstructionData() : discriminator = 5;

  final int discriminator;
}

Encoder<RevokeInstructionData> getRevokeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RevokeInstructionData value) => <String, Object?>{
      'discriminator': 5,
    },
  );
}

Decoder<RevokeInstructionData> getRevokeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'revoke instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RevokeInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(5),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RevokeInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RevokeInstructionData>(
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
      VariableSizeDecoder<RevokeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<RevokeInstructionData, RevokeInstructionData>
getRevokeInstructionDataCodec() {
  return combineCodec(
    getRevokeInstructionDataEncoder(),
    getRevokeInstructionDataDecoder(),
  );
}

/// Creates a [Revoke] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getRevokeInstruction({
  required Address programAddress,
  required Address source,
  required Address owner,

  bool ownerIsSigner = true,
}) {
  final instructionData = RevokeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: source, role: AccountRole.writable),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getRevokeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Revoke] instruction from raw instruction data.
RevokeInstructionData parseRevokeInstruction(Instruction instruction) {
  return getRevokeInstructionDataDecoder().decode(instruction.data!);
}
