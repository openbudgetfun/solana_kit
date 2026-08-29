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

import '../types/unlock_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UnlockInstructionData {
  const UnlockInstructionData({
    required this.unlockArgs,
  }) : discriminator = 47;

  final int discriminator;
  final UnlockArgs unlockArgs;
}

Encoder<UnlockInstructionData> getUnlockInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('unlockArgs', getUnlockArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UnlockInstructionData value) => <String, Object?>{
      'discriminator': 47,
      'unlockArgs': value.unlockArgs,
    },
  );
}

Decoder<UnlockInstructionData> getUnlockInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('unlockArgs', getUnlockArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'unlock instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UnlockInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(47),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UnlockInstructionData(
        unlockArgs: map['unlockArgs']! as UnlockArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UnlockInstructionData>(
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
      VariableSizeDecoder<UnlockInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UnlockInstructionData, UnlockInstructionData>
getUnlockInstructionDataCodec() {
  return combineCodec(
    getUnlockInstructionDataEncoder(),
    getUnlockInstructionDataDecoder(),
  );
}

/// Creates a [Unlock] instruction.
Instruction getUnlockInstruction({
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
  required UnlockArgs unlockArgs,
}) {
  final instructionData = UnlockInstructionData(
    unlockArgs: unlockArgs,
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
    data: getUnlockInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Unlock] instruction from raw instruction data.
UnlockInstructionData parseUnlockInstruction(Instruction instruction) {
  return getUnlockInstructionDataDecoder().decode(instruction.data!);
}
