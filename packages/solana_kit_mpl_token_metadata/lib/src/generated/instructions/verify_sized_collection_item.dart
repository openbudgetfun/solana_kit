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
class VerifySizedCollectionItemInstructionData {
  const VerifySizedCollectionItemInstructionData() : discriminator = 30;

  final int discriminator;
}

Encoder<VerifySizedCollectionItemInstructionData>
getVerifySizedCollectionItemInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VerifySizedCollectionItemInstructionData value) => <String, Object?>{
      'discriminator': 30,
    },
  );
}

Decoder<VerifySizedCollectionItemInstructionData>
getVerifySizedCollectionItemInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'verifySizedCollectionItem instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VerifySizedCollectionItemInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(30),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      VerifySizedCollectionItemInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VerifySizedCollectionItemInstructionData>(
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
      VariableSizeDecoder<VerifySizedCollectionItemInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  VerifySizedCollectionItemInstructionData,
  VerifySizedCollectionItemInstructionData
>
getVerifySizedCollectionItemInstructionDataCodec() {
  return combineCodec(
    getVerifySizedCollectionItemInstructionDataEncoder(),
    getVerifySizedCollectionItemInstructionDataDecoder(),
  );
}

/// Creates a [VerifySizedCollectionItem] instruction.
Instruction getVerifySizedCollectionItemInstruction({
  required Address programAddress,
  required Address metadata,
  required Address collectionAuthority,
  required Address payer,
  required Address collectionMint,
  required Address collection,
  required Address collectionMasterEditionAccount,
  Address? collectionAuthorityRecord,
}) {
  final instructionData = VerifySizedCollectionItemInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(
        address: collectionAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: collectionMint, role: AccountRole.readonly),
      AccountMeta(address: collection, role: AccountRole.writable),
      AccountMeta(
        address: collectionMasterEditionAccount,
        role: AccountRole.readonly,
      ),
      if (collectionAuthorityRecord != null)
        AccountMeta(
          address: collectionAuthorityRecord,
          role: AccountRole.readonly,
        ),
    ],
    data: getVerifySizedCollectionItemInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [VerifySizedCollectionItem] instruction from raw instruction data.
VerifySizedCollectionItemInstructionData
parseVerifySizedCollectionItemInstruction(Instruction instruction) {
  return getVerifySizedCollectionItemInstructionDataDecoder().decode(
    instruction.data!,
  );
}
