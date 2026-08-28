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

import '../types/delegate_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class DelegateInstructionData {
  const DelegateInstructionData({
    required this.delegateArgs,
  }) : discriminator = 44;

  final int discriminator;
  final DelegateArgs delegateArgs;
}

Encoder<DelegateInstructionData> getDelegateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('delegateArgs', getDelegateArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DelegateInstructionData value) => <String, Object?>{
      'discriminator': 44,
      'delegateArgs': value.delegateArgs,
    },
  );
}

Decoder<DelegateInstructionData> getDelegateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('delegateArgs', getDelegateArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'delegate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DelegateInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(44),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DelegateInstructionData(
        delegateArgs: map['delegateArgs']! as DelegateArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DelegateInstructionData>(
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
      VariableSizeDecoder<DelegateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<DelegateInstructionData, DelegateInstructionData>
getDelegateInstructionDataCodec() {
  return combineCodec(
    getDelegateInstructionDataEncoder(),
    getDelegateInstructionDataDecoder(),
  );
}

/// Creates a [Delegate] instruction.
Instruction getDelegateInstruction({
  required Address programAddress,
  Address? delegateRecord,
  required Address delegate,
  required Address metadata,
  Address? masterEdition,
  Address? tokenRecord,
  required Address mint,
  Address? token,
  required Address authority,
  required Address payer,
  required Address systemProgram,
  required Address sysvarInstructions,
  Address? splTokenProgram,
  Address? authorizationRulesProgram,
  Address? authorizationRules,
  required DelegateArgs delegateArgs,
}) {
  final instructionData = DelegateInstructionData(
    delegateArgs: delegateArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      if (delegateRecord != null)
        AccountMeta(address: delegateRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: delegate, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (masterEdition != null)
        AccountMeta(address: masterEdition, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (tokenRecord != null)
        AccountMeta(address: tokenRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      if (token != null)
        AccountMeta(address: token, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
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
    data: getDelegateInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Delegate] instruction from raw instruction data.
DelegateInstructionData parseDelegateInstruction(Instruction instruction) {
  return getDelegateInstructionDataDecoder().decode(instruction.data!);
}
