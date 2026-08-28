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

import '../types/collection_details.dart';
import '../types/data_v2.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateMetadataAccountV3InstructionData {
  const CreateMetadataAccountV3InstructionData({
    required this.data,
    required this.isMutable,
    required this.collectionDetails,
  }) : discriminator = 33;

  final int discriminator;
  final DataV2 data;
  final bool isMutable;
  final CollectionDetails? collectionDetails;
}

Encoder<CreateMetadataAccountV3InstructionData>
getCreateMetadataAccountV3InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('data', getDataV2Encoder()),
    ('isMutable', getBooleanEncoder()),
    (
      'collectionDetails',
      getNullableEncoder<CollectionDetails>(getCollectionDetailsEncoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateMetadataAccountV3InstructionData value) => <String, Object?>{
      'discriminator': 33,
      'data': value.data,
      'isMutable': value.isMutable,
      'collectionDetails': value.collectionDetails,
    },
  );
}

Decoder<CreateMetadataAccountV3InstructionData>
getCreateMetadataAccountV3InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('data', getDataV2Decoder()),
    ('isMutable', getBooleanDecoder()),
    (
      'collectionDetails',
      getNullableDecoder<CollectionDetails>(getCollectionDetailsDecoder()),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createMetadataAccountV3 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateMetadataAccountV3InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(33),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateMetadataAccountV3InstructionData(
        data: map['data']! as DataV2,
        isMutable: map['isMutable']! as bool,
        collectionDetails: map['collectionDetails'] as CollectionDetails?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateMetadataAccountV3InstructionData>(
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
      VariableSizeDecoder<CreateMetadataAccountV3InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  CreateMetadataAccountV3InstructionData,
  CreateMetadataAccountV3InstructionData
>
getCreateMetadataAccountV3InstructionDataCodec() {
  return combineCodec(
    getCreateMetadataAccountV3InstructionDataEncoder(),
    getCreateMetadataAccountV3InstructionDataDecoder(),
  );
}

/// Creates a [CreateMetadataAccountV3] instruction.
Instruction getCreateMetadataAccountV3Instruction({
  required Address programAddress,
  required Address metadata,
  required Address mint,
  required Address mintAuthority,
  required Address payer,
  required Address updateAuthority,
  required Address systemProgram,
  Address? rent,
  required DataV2 data,
  required bool isMutable,
  required CollectionDetails? collectionDetails,
}) {
  final instructionData = CreateMetadataAccountV3InstructionData(
    data: data,
    isMutable: isMutable,
    collectionDetails: collectionDetails,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (rent != null) AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getCreateMetadataAccountV3InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateMetadataAccountV3] instruction from raw instruction data.
CreateMetadataAccountV3InstructionData parseCreateMetadataAccountV3Instruction(
  Instruction instruction,
) {
  return getCreateMetadataAccountV3InstructionDataDecoder().decode(
    instruction.data!,
  );
}
