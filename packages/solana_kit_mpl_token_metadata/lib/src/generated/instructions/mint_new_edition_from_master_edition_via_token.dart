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

import '../types/mint_new_edition_from_master_edition_via_token_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class MintNewEditionFromMasterEditionViaTokenInstructionData {
  const MintNewEditionFromMasterEditionViaTokenInstructionData({
    required this.mintNewEditionFromMasterEditionViaTokenArgs,
  }) : discriminator = 11;

  final int discriminator;
  final MintNewEditionFromMasterEditionViaTokenArgs
  mintNewEditionFromMasterEditionViaTokenArgs;
}

Encoder<MintNewEditionFromMasterEditionViaTokenInstructionData>
getMintNewEditionFromMasterEditionViaTokenInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'mintNewEditionFromMasterEditionViaTokenArgs',
      getMintNewEditionFromMasterEditionViaTokenArgsEncoder(),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (MintNewEditionFromMasterEditionViaTokenInstructionData value) =>
        <String, Object?>{
          'discriminator': 11,
          'mintNewEditionFromMasterEditionViaTokenArgs':
              value.mintNewEditionFromMasterEditionViaTokenArgs,
        },
  );
}

Decoder<MintNewEditionFromMasterEditionViaTokenInstructionData>
getMintNewEditionFromMasterEditionViaTokenInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'mintNewEditionFromMasterEditionViaTokenArgs',
      getMintNewEditionFromMasterEditionViaTokenArgsDecoder(),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'mintNewEditionFromMasterEditionViaToken instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MintNewEditionFromMasterEditionViaTokenInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(11),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MintNewEditionFromMasterEditionViaTokenInstructionData(
        mintNewEditionFromMasterEditionViaTokenArgs:
            map['mintNewEditionFromMasterEditionViaTokenArgs']!
                as MintNewEditionFromMasterEditionViaTokenArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MintNewEditionFromMasterEditionViaTokenInstructionData>(
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
        MintNewEditionFromMasterEditionViaTokenInstructionData
      >(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  MintNewEditionFromMasterEditionViaTokenInstructionData,
  MintNewEditionFromMasterEditionViaTokenInstructionData
>
getMintNewEditionFromMasterEditionViaTokenInstructionDataCodec() {
  return combineCodec(
    getMintNewEditionFromMasterEditionViaTokenInstructionDataEncoder(),
    getMintNewEditionFromMasterEditionViaTokenInstructionDataDecoder(),
  );
}

/// Creates a [MintNewEditionFromMasterEditionViaToken] instruction.
Instruction getMintNewEditionFromMasterEditionViaTokenInstruction({
  required Address programAddress,
  required Address newMetadata,
  required Address newEdition,
  required Address masterEdition,
  required Address newMint,
  required Address editionMarkPda,
  required Address newMintAuthority,
  required Address payer,
  required Address tokenAccountOwner,
  required Address tokenAccount,
  required Address newMetadataUpdateAuthority,
  required Address metadata,
  required Address tokenProgram,
  required Address systemProgram,
  Address? rent,
  required MintNewEditionFromMasterEditionViaTokenArgs
  mintNewEditionFromMasterEditionViaTokenArgs,
}) {
  final instructionData =
      MintNewEditionFromMasterEditionViaTokenInstructionData(
        mintNewEditionFromMasterEditionViaTokenArgs:
            mintNewEditionFromMasterEditionViaTokenArgs,
      );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: newMetadata, role: AccountRole.writable),
      AccountMeta(address: newEdition, role: AccountRole.writable),
      AccountMeta(address: masterEdition, role: AccountRole.writable),
      AccountMeta(address: newMint, role: AccountRole.writable),
      AccountMeta(address: editionMarkPda, role: AccountRole.writable),
      AccountMeta(address: newMintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: tokenAccountOwner, role: AccountRole.readonlySigner),
      AccountMeta(address: tokenAccount, role: AccountRole.readonly),
      AccountMeta(
        address: newMetadataUpdateAuthority,
        role: AccountRole.readonly,
      ),
      AccountMeta(address: metadata, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getMintNewEditionFromMasterEditionViaTokenInstructionDataEncoder()
        .encode(instructionData),
  );
}

/// Parses a [MintNewEditionFromMasterEditionViaToken] instruction from raw instruction data.
MintNewEditionFromMasterEditionViaTokenInstructionData
parseMintNewEditionFromMasterEditionViaTokenInstruction(
  Instruction instruction,
) {
  return getMintNewEditionFromMasterEditionViaTokenInstructionDataDecoder()
      .decode(instruction.data!);
}
