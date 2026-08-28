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
class BurnEditionNftInstructionData {
  const BurnEditionNftInstructionData() : discriminator = 37;

  final int discriminator;
}

Encoder<BurnEditionNftInstructionData>
getBurnEditionNftInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnEditionNftInstructionData value) => <String, Object?>{
      'discriminator': 37,
    },
  );
}

Decoder<BurnEditionNftInstructionData>
getBurnEditionNftInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'burnEditionNft instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BurnEditionNftInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BurnEditionNftInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BurnEditionNftInstructionData>(
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
      VariableSizeDecoder<BurnEditionNftInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BurnEditionNftInstructionData, BurnEditionNftInstructionData>
getBurnEditionNftInstructionDataCodec() {
  return combineCodec(
    getBurnEditionNftInstructionDataEncoder(),
    getBurnEditionNftInstructionDataDecoder(),
  );
}

/// Creates a [BurnEditionNft] instruction.
Instruction getBurnEditionNftInstruction({
  required Address programAddress,
  required Address metadata,
  required Address owner,
  required Address printEditionMint,
  required Address masterEditionMint,
  required Address printEditionTokenAccount,
  required Address masterEditionTokenAccount,
  required Address masterEditionAccount,
  required Address printEditionAccount,
  required Address editionMarkerAccount,
  required Address splTokenProgram,
}) {
  final instructionData = BurnEditionNftInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: owner, role: AccountRole.writableSigner),
      AccountMeta(address: printEditionMint, role: AccountRole.writable),
      AccountMeta(address: masterEditionMint, role: AccountRole.readonly),
      AccountMeta(
        address: printEditionTokenAccount,
        role: AccountRole.writable,
      ),
      AccountMeta(
        address: masterEditionTokenAccount,
        role: AccountRole.readonly,
      ),
      AccountMeta(address: masterEditionAccount, role: AccountRole.writable),
      AccountMeta(address: printEditionAccount, role: AccountRole.writable),
      AccountMeta(address: editionMarkerAccount, role: AccountRole.writable),
      AccountMeta(address: splTokenProgram, role: AccountRole.readonly),
    ],
    data: getBurnEditionNftInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [BurnEditionNft] instruction from raw instruction data.
BurnEditionNftInstructionData parseBurnEditionNftInstruction(
  Instruction instruction,
) {
  return getBurnEditionNftInstructionDataDecoder().decode(instruction.data!);
}
