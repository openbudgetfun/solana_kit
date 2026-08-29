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

import '../types/print_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class PrintInstructionData {
  const PrintInstructionData({
    required this.printArgs,
  }) : discriminator = 55;

  final int discriminator;
  final PrintArgs printArgs;
}

Encoder<PrintInstructionData> getPrintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('printArgs', getPrintArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (PrintInstructionData value) => <String, Object?>{
      'discriminator': 55,
      'printArgs': value.printArgs,
    },
  );
}

Decoder<PrintInstructionData> getPrintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('printArgs', getPrintArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'print instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (PrintInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(55),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      PrintInstructionData(
        printArgs: map['printArgs']! as PrintArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<PrintInstructionData>(
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
      VariableSizeDecoder<PrintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<PrintInstructionData, PrintInstructionData>
getPrintInstructionDataCodec() {
  return combineCodec(
    getPrintInstructionDataEncoder(),
    getPrintInstructionDataDecoder(),
  );
}

/// Creates a [Print] instruction.
Instruction getPrintInstruction({
  required Address programAddress,
  required Address editionMetadata,
  required Address edition,
  required Address editionMint,
  required Address editionTokenAccountOwner,
  required Address editionTokenAccount,
  required Address editionMintAuthority,
  Address? editionTokenRecord,
  required Address masterEdition,
  required Address editionMarkerPda,
  required Address payer,
  required Address masterTokenAccountOwner,
  required Address masterTokenAccount,
  required Address masterMetadata,
  required Address updateAuthority,
  required Address splTokenProgram,
  required Address splAtaProgram,
  required Address sysvarInstructions,
  required Address systemProgram,
  required PrintArgs printArgs,
}) {
  final instructionData = PrintInstructionData(
    printArgs: printArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: editionMetadata, role: AccountRole.writable),
      AccountMeta(address: edition, role: AccountRole.writable),
      AccountMeta(address: editionMint, role: AccountRole.writable),
      AccountMeta(
        address: editionTokenAccountOwner,
        role: AccountRole.readonly,
      ),
      AccountMeta(address: editionTokenAccount, role: AccountRole.writable),
      AccountMeta(
        address: editionMintAuthority,
        role: AccountRole.readonlySigner,
      ),
      if (editionTokenRecord != null)
        AccountMeta(address: editionTokenRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: masterEdition, role: AccountRole.writable),
      AccountMeta(address: editionMarkerPda, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(
        address: masterTokenAccountOwner,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(address: masterTokenAccount, role: AccountRole.readonly),
      AccountMeta(address: masterMetadata, role: AccountRole.readonly),
      AccountMeta(address: updateAuthority, role: AccountRole.readonly),
      AccountMeta(address: splTokenProgram, role: AccountRole.readonly),
      AccountMeta(address: splAtaProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getPrintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Print] instruction from raw instruction data.
PrintInstructionData parsePrintInstruction(Instruction instruction) {
  return getPrintInstructionDataDecoder().decode(instruction.data!);
}
