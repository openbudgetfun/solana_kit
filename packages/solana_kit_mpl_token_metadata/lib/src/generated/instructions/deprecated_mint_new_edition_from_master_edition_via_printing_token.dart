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
class DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData {
  const DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData()
    : discriminator = 3;

  final int discriminator;
}

Encoder<
  DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
>
getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (
      DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
      value,
    ) => <String, Object?>{
      'discriminator': 3,
    },
  );
}

Decoder<
  DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
>
getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'deprecatedMintNewEditionFromMasterEditionViaPrintingToken instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (
    DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData,
    int,
  )
  readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(3),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<
        DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
      >(
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
      VariableSizeDecoder<
        DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData,
  DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
>
getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionDataCodec() {
  return combineCodec(
    getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionDataEncoder(),
    getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionDataDecoder(),
  );
}

/// Creates a [DeprecatedMintNewEditionFromMasterEditionViaPrintingToken] instruction.
Instruction
getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstruction({
  required Address programAddress,
  required Address metadata,
  required Address edition,
  required Address masterEdition,
  required Address mint,
  required Address mintAuthority,
  required Address printingMint,
  required Address masterTokenAccount,
  required Address editionMarker,
  required Address burnAuthority,
  required Address payer,
  required Address masterUpdateAuthority,
  required Address masterMetadata,
  required Address tokenProgram,
  required Address systemProgram,
  required Address rent,
  Address? reservationList,
}) {
  final instructionData =
      DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: edition, role: AccountRole.writable),
      AccountMeta(address: masterEdition, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: printingMint, role: AccountRole.writable),
      AccountMeta(address: masterTokenAccount, role: AccountRole.writable),
      AccountMeta(address: editionMarker, role: AccountRole.writable),
      AccountMeta(address: burnAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: masterUpdateAuthority, role: AccountRole.readonly),
      AccountMeta(address: masterMetadata, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
      if (reservationList != null)
        AccountMeta(address: reservationList, role: AccountRole.writable),
    ],
    data:
        getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionDataEncoder()
            .encode(instructionData),
  );
}

/// Parses a [DeprecatedMintNewEditionFromMasterEditionViaPrintingToken] instruction from raw instruction data.
DeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionData
parseDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstruction(
  Instruction instruction,
) {
  return getDeprecatedMintNewEditionFromMasterEditionViaPrintingTokenInstructionDataDecoder()
      .decode(instruction.data!);
}
