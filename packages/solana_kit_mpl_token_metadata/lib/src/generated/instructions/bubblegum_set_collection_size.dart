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

import '../types/set_collection_size_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class BubblegumSetCollectionSizeInstructionData {
  const BubblegumSetCollectionSizeInstructionData({
    required this.setCollectionSizeArgs,
  }) : discriminator = 36;

  final int discriminator;
  final SetCollectionSizeArgs setCollectionSizeArgs;
}

Encoder<BubblegumSetCollectionSizeInstructionData>
getBubblegumSetCollectionSizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('setCollectionSizeArgs', getSetCollectionSizeArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (BubblegumSetCollectionSizeInstructionData value) => <String, Object?>{
      'discriminator': 36,
      'setCollectionSizeArgs': value.setCollectionSizeArgs,
    },
  );
}

Decoder<BubblegumSetCollectionSizeInstructionData>
getBubblegumSetCollectionSizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('setCollectionSizeArgs', getSetCollectionSizeArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'bubblegumSetCollectionSize instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BubblegumSetCollectionSizeInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(36),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BubblegumSetCollectionSizeInstructionData(
        setCollectionSizeArgs:
            map['setCollectionSizeArgs']! as SetCollectionSizeArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BubblegumSetCollectionSizeInstructionData>(
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
      VariableSizeDecoder<BubblegumSetCollectionSizeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  BubblegumSetCollectionSizeInstructionData,
  BubblegumSetCollectionSizeInstructionData
>
getBubblegumSetCollectionSizeInstructionDataCodec() {
  return combineCodec(
    getBubblegumSetCollectionSizeInstructionDataEncoder(),
    getBubblegumSetCollectionSizeInstructionDataDecoder(),
  );
}

/// Creates a [BubblegumSetCollectionSize] instruction.
Instruction getBubblegumSetCollectionSizeInstruction({
  required Address programAddress,
  required Address collectionMetadata,
  required Address collectionAuthority,
  required Address collectionMint,
  required Address bubblegumSigner,
  Address? collectionAuthorityRecord,
  required SetCollectionSizeArgs setCollectionSizeArgs,
}) {
  final instructionData = BubblegumSetCollectionSizeInstructionData(
    setCollectionSizeArgs: setCollectionSizeArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collectionMetadata, role: AccountRole.writable),
      AccountMeta(
        address: collectionAuthority,
        role: AccountRole.readonlySigner,
      ),
      AccountMeta(address: collectionMint, role: AccountRole.readonly),
      AccountMeta(address: bubblegumSigner, role: AccountRole.readonlySigner),
      if (collectionAuthorityRecord != null)
        AccountMeta(
          address: collectionAuthorityRecord,
          role: AccountRole.readonly,
        ),
    ],
    data: getBubblegumSetCollectionSizeInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [BubblegumSetCollectionSize] instruction from raw instruction data.
BubblegumSetCollectionSizeInstructionData
parseBubblegumSetCollectionSizeInstruction(Instruction instruction) {
  return getBubblegumSetCollectionSizeInstructionDataDecoder().decode(
    instruction.data!,
  );
}
