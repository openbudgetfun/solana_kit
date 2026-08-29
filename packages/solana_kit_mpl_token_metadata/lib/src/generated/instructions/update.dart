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

import '../types/update_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateInstructionData {
  const UpdateInstructionData({
    required this.updateArgs,
  }) : discriminator = 50;

  final int discriminator;
  final UpdateArgs updateArgs;
}

Encoder<UpdateInstructionData> getUpdateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('updateArgs', getUpdateArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateInstructionData value) => <String, Object?>{
      'discriminator': 50,
      'updateArgs': value.updateArgs,
    },
  );
}

Decoder<UpdateInstructionData> getUpdateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('updateArgs', getUpdateArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'update instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(50),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateInstructionData(
        updateArgs: map['updateArgs']! as UpdateArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateInstructionData>(
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
      VariableSizeDecoder<UpdateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateInstructionData, UpdateInstructionData>
getUpdateInstructionDataCodec() {
  return combineCodec(
    getUpdateInstructionDataEncoder(),
    getUpdateInstructionDataDecoder(),
  );
}

/// Creates a [Update] instruction.
Instruction getUpdateInstruction({
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
  Address? authorizationRulesProgram,
  Address? authorizationRules,
  required UpdateArgs updateArgs,
}) {
  final instructionData = UpdateInstructionData(
    updateArgs: updateArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      if (delegateRecord != null)
        AccountMeta(address: delegateRecord, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (token != null)
        AccountMeta(address: token, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (edition != null)
        AccountMeta(address: edition, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
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
    data: getUpdateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Update] instruction from raw instruction data.
UpdateInstructionData parseUpdateInstruction(Instruction instruction) {
  return getUpdateInstructionDataDecoder().decode(instruction.data!);
}
