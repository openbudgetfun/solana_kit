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
class SetCollectionSizeInstructionData {
  const SetCollectionSizeInstructionData({
    required this.setCollectionSizeArgs,
  }) : discriminator = 34;

  final int discriminator;
  final SetCollectionSizeArgs setCollectionSizeArgs;
}

Encoder<SetCollectionSizeInstructionData>
getSetCollectionSizeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('setCollectionSizeArgs', getSetCollectionSizeArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetCollectionSizeInstructionData value) => <String, Object?>{
      'discriminator': 34,
      'setCollectionSizeArgs': value.setCollectionSizeArgs,
    },
  );
}

Decoder<SetCollectionSizeInstructionData>
getSetCollectionSizeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('setCollectionSizeArgs', getSetCollectionSizeArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'setCollectionSize instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SetCollectionSizeInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(34),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      SetCollectionSizeInstructionData(
        setCollectionSizeArgs:
            map['setCollectionSizeArgs']! as SetCollectionSizeArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SetCollectionSizeInstructionData>(
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
      VariableSizeDecoder<SetCollectionSizeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SetCollectionSizeInstructionData, SetCollectionSizeInstructionData>
getSetCollectionSizeInstructionDataCodec() {
  return combineCodec(
    getSetCollectionSizeInstructionDataEncoder(),
    getSetCollectionSizeInstructionDataDecoder(),
  );
}

/// Creates a [SetCollectionSize] instruction.
Instruction getSetCollectionSizeInstruction({
  required Address programAddress,
  required Address collectionMetadata,
  required Address collectionAuthority,
  required Address collectionMint,
  Address? collectionAuthorityRecord,
  required SetCollectionSizeArgs setCollectionSizeArgs,
}) {
  final instructionData = SetCollectionSizeInstructionData(
    setCollectionSizeArgs: setCollectionSizeArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collectionMetadata, role: AccountRole.writable),
      AccountMeta(
        address: collectionAuthority,
        role: AccountRole.writableSigner,
      ),
      AccountMeta(address: collectionMint, role: AccountRole.readonly),
      if (collectionAuthorityRecord != null)
        AccountMeta(
          address: collectionAuthorityRecord,
          role: AccountRole.readonly,
        ),
    ],
    data: getSetCollectionSizeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetCollectionSize] instruction from raw instruction data.
SetCollectionSizeInstructionData parseSetCollectionSizeInstruction(
  Instruction instruction,
) {
  return getSetCollectionSizeInstructionDataDecoder().decode(instruction.data!);
}
