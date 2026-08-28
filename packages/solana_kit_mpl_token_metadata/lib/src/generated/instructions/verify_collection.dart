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
class VerifyCollectionInstructionData {
  const VerifyCollectionInstructionData() : discriminator = 18;

  final int discriminator;
}

Encoder<VerifyCollectionInstructionData>
getVerifyCollectionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (VerifyCollectionInstructionData value) => <String, Object?>{
      'discriminator': 18,
    },
  );
}

Decoder<VerifyCollectionInstructionData>
getVerifyCollectionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'verifyCollection instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (VerifyCollectionInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(18),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      VerifyCollectionInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<VerifyCollectionInstructionData>(
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
      VariableSizeDecoder<VerifyCollectionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<VerifyCollectionInstructionData, VerifyCollectionInstructionData>
getVerifyCollectionInstructionDataCodec() {
  return combineCodec(
    getVerifyCollectionInstructionDataEncoder(),
    getVerifyCollectionInstructionDataDecoder(),
  );
}

/// Creates a [VerifyCollection] instruction.
Instruction getVerifyCollectionInstruction({
  required Address programAddress,
  required Address metadata,
  required Address collectionAuthority,
  required Address payer,
  required Address collectionMint,
  required Address collection,
  required Address collectionMasterEditionAccount,
  Address? collectionAuthorityRecord,
}) {
  final instructionData = VerifyCollectionInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(
        address: collectionAuthority,
        role: AccountRole.writableSigner,
      ),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: collectionMint, role: AccountRole.readonly),
      AccountMeta(address: collection, role: AccountRole.readonly),
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
    data: getVerifyCollectionInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [VerifyCollection] instruction from raw instruction data.
VerifyCollectionInstructionData parseVerifyCollectionInstruction(
  Instruction instruction,
) {
  return getVerifyCollectionInstructionDataDecoder().decode(instruction.data!);
}
