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

import '../types/mint_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MintInstructionData {
  const MintInstructionData({
    required this.mintArgs,
  }) : discriminator = 43;

  final int discriminator;
  final MintArgs mintArgs;
}

Encoder<MintInstructionData> getMintInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('mintArgs', getMintArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MintInstructionData value) => <String, Object?>{
      'discriminator': 43,
      'mintArgs': value.mintArgs,
    },
  );
}

Decoder<MintInstructionData> getMintInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('mintArgs', getMintArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'mint instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MintInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(43),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MintInstructionData(
        mintArgs: map['mintArgs']! as MintArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MintInstructionData>(
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
      VariableSizeDecoder<MintInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MintInstructionData, MintInstructionData> getMintInstructionDataCodec() {
  return combineCodec(
    getMintInstructionDataEncoder(),
    getMintInstructionDataDecoder(),
  );
}

/// Creates a [Mint] instruction.
Instruction getMintInstruction({
  required Address programAddress,
  required Address token,
  Address? tokenOwner,
  required Address metadata,
  Address? masterEdition,
  Address? tokenRecord,
  required Address mint,
  required Address authority,
  Address? delegateRecord,
  required Address payer,
  required Address systemProgram,
  required Address sysvarInstructions,
  required Address splTokenProgram,
  required Address splAtaProgram,
  Address? authorizationRulesProgram,
  Address? authorizationRules,
  required MintArgs mintArgs,
}) {
  final instructionData = MintInstructionData(
    mintArgs: mintArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      if (tokenOwner != null)
        AccountMeta(address: tokenOwner, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      if (masterEdition != null)
        AccountMeta(address: masterEdition, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (tokenRecord != null)
        AccountMeta(address: tokenRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      if (delegateRecord != null)
        AccountMeta(address: delegateRecord, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      AccountMeta(address: splTokenProgram, role: AccountRole.readonly),
      AccountMeta(address: splAtaProgram, role: AccountRole.readonly),
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
    data: getMintInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Mint] instruction from raw instruction data.
MintInstructionData parseMintInstruction(Instruction instruction) {
  return getMintInstructionDataDecoder().decode(instruction.data!);
}
