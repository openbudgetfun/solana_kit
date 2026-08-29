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
class DeprecatedCreateMasterEditionInstructionData {
  const DeprecatedCreateMasterEditionInstructionData() : discriminator = 2;

  final int discriminator;
}

Encoder<DeprecatedCreateMasterEditionInstructionData>
getDeprecatedCreateMasterEditionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DeprecatedCreateMasterEditionInstructionData value) => <String, Object?>{
      'discriminator': 2,
    },
  );
}

Decoder<DeprecatedCreateMasterEditionInstructionData>
getDeprecatedCreateMasterEditionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'deprecatedCreateMasterEdition instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DeprecatedCreateMasterEditionInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DeprecatedCreateMasterEditionInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DeprecatedCreateMasterEditionInstructionData>(
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
      VariableSizeDecoder<DeprecatedCreateMasterEditionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DeprecatedCreateMasterEditionInstructionData,
  DeprecatedCreateMasterEditionInstructionData
>
getDeprecatedCreateMasterEditionInstructionDataCodec() {
  return combineCodec(
    getDeprecatedCreateMasterEditionInstructionDataEncoder(),
    getDeprecatedCreateMasterEditionInstructionDataDecoder(),
  );
}

/// Creates a [DeprecatedCreateMasterEdition] instruction.
Instruction getDeprecatedCreateMasterEditionInstruction({
  required Address programAddress,
  required Address edition,
  required Address mint,
  required Address printingMint,
  required Address oneTimePrintingAuthorizationMint,
  required Address updateAuthority,
  required Address printingMintAuthority,
  required Address mintAuthority,
  required Address metadata,
  required Address payer,
  required Address tokenProgram,
  required Address systemProgram,
  required Address rent,
  required Address oneTimePrintingAuthorizationMintAuthority,
}) {
  final instructionData = DeprecatedCreateMasterEditionInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: edition, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: printingMint, role: AccountRole.writable),
      AccountMeta(
        address: oneTimePrintingAuthorizationMint,
        role: AccountRole.writable,
      ),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
      AccountMeta(
        address: printingMintAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
      AccountMeta(
        address: oneTimePrintingAuthorizationMintAuthority,
        role: AccountRole.readonlySigner,
      ),
    ],
    data: getDeprecatedCreateMasterEditionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DeprecatedCreateMasterEdition] instruction from raw instruction data.
DeprecatedCreateMasterEditionInstructionData
parseDeprecatedCreateMasterEditionInstruction(Instruction instruction) {
  return getDeprecatedCreateMasterEditionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
