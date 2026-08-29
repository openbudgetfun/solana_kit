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

import '../types/burn_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class BurnInstructionData {
  const BurnInstructionData({
    required this.burnArgs,
  }) : discriminator = 41;

  final int discriminator;
  final BurnArgs burnArgs;
}

Encoder<BurnInstructionData> getBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('burnArgs', getBurnArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnInstructionData value) => <String, Object?>{
      'discriminator': 41,
      'burnArgs': value.burnArgs,
    },
  );
}

Decoder<BurnInstructionData> getBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('burnArgs', getBurnArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'burn instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BurnInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(41),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BurnInstructionData(
        burnArgs: map['burnArgs']! as BurnArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BurnInstructionData>(
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
      VariableSizeDecoder<BurnInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BurnInstructionData, BurnInstructionData> getBurnInstructionDataCodec() {
  return combineCodec(
    getBurnInstructionDataEncoder(),
    getBurnInstructionDataDecoder(),
  );
}

/// Creates a [Burn] instruction.
Instruction getBurnInstruction({
  required Address programAddress,
  required Address authority,
  Address? collectionMetadata,
  required Address metadata,
  Address? edition,
  required Address mint,
  required Address token,
  Address? masterEdition,
  Address? masterEditionMint,
  Address? masterEditionToken,
  Address? editionMarker,
  Address? tokenRecord,
  required Address systemProgram,
  required Address sysvarInstructions,
  required Address splTokenProgram,
  required BurnArgs burnArgs,
}) {
  final instructionData = BurnInstructionData(
    burnArgs: burnArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: authority, role: AccountRole.writableSigner),
      if (collectionMetadata != null)
        AccountMeta(address: collectionMetadata, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (edition != null)
        AccountMeta(address: edition, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: token, role: AccountRole.writable),
      if (masterEdition != null)
        AccountMeta(address: masterEdition, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (masterEditionMint != null)
        AccountMeta(address: masterEditionMint, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (masterEditionToken != null)
        AccountMeta(address: masterEditionToken, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (editionMarker != null)
        AccountMeta(address: editionMarker, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (tokenRecord != null)
        AccountMeta(address: tokenRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      AccountMeta(address: splTokenProgram, role: AccountRole.readonly),
    ],
    data: getBurnInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Burn] instruction from raw instruction data.
BurnInstructionData parseBurnInstruction(Instruction instruction) {
  return getBurnInstructionDataDecoder().decode(instruction.data!);
}
