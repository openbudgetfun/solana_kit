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

import '../types/lock_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class LockInstructionData {
  const LockInstructionData({
    required this.lockArgs,
  }) : discriminator = 46;

  final int discriminator;
  final LockArgs lockArgs;
}

Encoder<LockInstructionData> getLockInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('lockArgs', getLockArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (LockInstructionData value) => <String, Object?>{
      'discriminator': 46,
      'lockArgs': value.lockArgs,
    },
  );
}

Decoder<LockInstructionData> getLockInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('lockArgs', getLockArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'lock instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (LockInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(46),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      LockInstructionData(
        lockArgs: map['lockArgs']! as LockArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<LockInstructionData>(
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
      VariableSizeDecoder<LockInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<LockInstructionData, LockInstructionData> getLockInstructionDataCodec() {
  return combineCodec(
    getLockInstructionDataEncoder(),
    getLockInstructionDataDecoder(),
  );
}

/// Creates a [Lock] instruction.
Instruction getLockInstruction({
  required Address programAddress,
  required Address authority,
  Address? tokenOwner,
  required Address token,
  required Address mint,
  required Address metadata,
  Address? edition,
  Address? tokenRecord,
  required Address payer,
  required Address systemProgram,
  required Address sysvarInstructions,
  Address? splTokenProgram,
  Address? authorizationRulesProgram,
  Address? authorizationRules,
  required LockArgs lockArgs,
}) {
  final instructionData = LockInstructionData(
    lockArgs: lockArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      if (tokenOwner != null)
        AccountMeta(address: tokenOwner, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (edition != null)
        AccountMeta(address: edition, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (tokenRecord != null)
        AccountMeta(address: tokenRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
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
    data: getLockInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Lock] instruction from raw instruction data.
LockInstructionData parseLockInstruction(Instruction instruction) {
  return getLockInstructionDataDecoder().decode(instruction.data!);
}
