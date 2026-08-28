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
class MigrateInstructionData {
  const MigrateInstructionData() : discriminator = 48;

  final int discriminator;
}

Encoder<MigrateInstructionData> getMigrateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MigrateInstructionData value) => <String, Object?>{
      'discriminator': 48,
    },
  );
}

Decoder<MigrateInstructionData> getMigrateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'migrate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MigrateInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(48),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MigrateInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MigrateInstructionData>(
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
      VariableSizeDecoder<MigrateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MigrateInstructionData, MigrateInstructionData>
getMigrateInstructionDataCodec() {
  return combineCodec(
    getMigrateInstructionDataEncoder(),
    getMigrateInstructionDataDecoder(),
  );
}

/// Creates a [Migrate] instruction.
Instruction getMigrateInstruction({
  required Address programAddress,
  required Address metadata,
  required Address edition,
  required Address token,
  required Address tokenOwner,
  required Address mint,
  required Address payer,
  required Address authority,
  required Address collectionMetadata,
  required Address delegateRecord,
  required Address tokenRecord,
  required Address systemProgram,
  required Address sysvarInstructions,
  required Address splTokenProgram,
  Address? authorizationRulesProgram,
  Address? authorizationRules,
}) {
  final instructionData = MigrateInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: edition, role: AccountRole.writable),
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: tokenOwner, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: collectionMetadata, role: AccountRole.readonly),
      AccountMeta(address: delegateRecord, role: AccountRole.readonly),
      AccountMeta(address: tokenRecord, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      AccountMeta(address: splTokenProgram, role: AccountRole.readonly),
      if (authorizationRulesProgram != null)
        AccountMeta(
          address: authorizationRulesProgram,
          role: AccountRole.readonly,
        )
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (authorizationRules != null)
        AccountMeta(address: authorizationRules, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getMigrateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Migrate] instruction from raw instruction data.
MigrateInstructionData parseMigrateInstruction(Instruction instruction) {
  return getMigrateInstructionDataDecoder().decode(instruction.data!);
}
