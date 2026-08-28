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

import '../types/use_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UseInstructionData {
  const UseInstructionData({
    required this.useArgs,
  }) : discriminator = 51;

  final int discriminator;
  final UseArgs useArgs;
}

Encoder<UseInstructionData> getUseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('useArgs', getUseArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UseInstructionData value) => <String, Object?>{
      'discriminator': 51,
      'useArgs': value.useArgs,
    },
  );
}

Decoder<UseInstructionData> getUseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('useArgs', getUseArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'use instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UseInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(51),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UseInstructionData(
        useArgs: map['useArgs']! as UseArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UseInstructionData>(
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
      VariableSizeDecoder<UseInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UseInstructionData, UseInstructionData> getUseInstructionDataCodec() {
  return combineCodec(
    getUseInstructionDataEncoder(),
    getUseInstructionDataDecoder(),
  );
}

/// Creates a [Use] instruction.
Instruction getUseInstruction({
  required Address programAddress,
  required Address authority,
  Address? delegateRecord,
  Address? token,
  required Address mint,
  required Address metadata,
  Address? edition,
  required Address payer,
  required Address systemProgram,
  required Address sysvarInstructions,
  Address? splTokenProgram,
  Address? authorizationRulesProgram,
  Address? authorizationRules,
  required UseArgs useArgs,
}) {
  final instructionData = UseInstructionData(
    useArgs: useArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      if (delegateRecord != null)
        AccountMeta(address: delegateRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (token != null)
        AccountMeta(address: token, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (edition != null)
        AccountMeta(address: edition, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.readonlySigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      if (splTokenProgram != null)
        AccountMeta(address: splTokenProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
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
    data: getUseInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Use] instruction from raw instruction data.
UseInstructionData parseUseInstruction(Instruction instruction) {
  return getUseInstructionDataDecoder().decode(instruction.data!);
}
