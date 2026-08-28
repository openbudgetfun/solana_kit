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

import '../types/data_v2.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateMetadataAccountV2InstructionData {
  const UpdateMetadataAccountV2InstructionData({
    required this.data,
    required this.newUpdateAuthority,
    required this.primarySaleHappened,
    required this.isMutable,
  }) : discriminator = 15;

  final int discriminator;
  final DataV2? data;
  final Address? newUpdateAuthority;
  final bool? primarySaleHappened;
  final bool? isMutable;
}

Encoder<UpdateMetadataAccountV2InstructionData>
getUpdateMetadataAccountV2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('data', getNullableEncoder<DataV2>(getDataV2Encoder())),
    ('newUpdateAuthority', getNullableEncoder<Address>(getAddressEncoder())),
    ('primarySaleHappened', getNullableEncoder<bool>(getBooleanEncoder())),
    ('isMutable', getNullableEncoder<bool>(getBooleanEncoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateMetadataAccountV2InstructionData value) => <String, Object?>{
      'discriminator': 15,
      'data': value.data,
      'newUpdateAuthority': value.newUpdateAuthority,
      'primarySaleHappened': value.primarySaleHappened,
      'isMutable': value.isMutable,
    },
  );
}

Decoder<UpdateMetadataAccountV2InstructionData>
getUpdateMetadataAccountV2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('data', getNullableDecoder<DataV2>(getDataV2Decoder())),
    ('newUpdateAuthority', getNullableDecoder<Address>(getAddressDecoder())),
    ('primarySaleHappened', getNullableDecoder<bool>(getBooleanDecoder())),
    ('isMutable', getNullableDecoder<bool>(getBooleanDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateMetadataAccountV2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateMetadataAccountV2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(15),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateMetadataAccountV2InstructionData(
        data: map['data'] as DataV2?,
        newUpdateAuthority: map['newUpdateAuthority'] as Address?,
        primarySaleHappened: map['primarySaleHappened'] as bool?,
        isMutable: map['isMutable'] as bool?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateMetadataAccountV2InstructionData>(
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
      VariableSizeDecoder<UpdateMetadataAccountV2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateMetadataAccountV2InstructionData,
  UpdateMetadataAccountV2InstructionData
>
getUpdateMetadataAccountV2InstructionDataCodec() {
  return combineCodec(
    getUpdateMetadataAccountV2InstructionDataEncoder(),
    getUpdateMetadataAccountV2InstructionDataDecoder(),
  );
}

/// Creates a [UpdateMetadataAccountV2] instruction.
Instruction getUpdateMetadataAccountV2Instruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required DataV2? data,
  required Address? newUpdateAuthority,
  required bool? primarySaleHappened,
  required bool? isMutable,
}) {
  final instructionData = UpdateMetadataAccountV2InstructionData(
    data: data,
    newUpdateAuthority: newUpdateAuthority,
    primarySaleHappened: primarySaleHappened,
    isMutable: isMutable,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner),
    ],
    data: getUpdateMetadataAccountV2InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateMetadataAccountV2] instruction from raw instruction data.
UpdateMetadataAccountV2InstructionData parseUpdateMetadataAccountV2Instruction(
  Instruction instruction,
) {
  return getUpdateMetadataAccountV2InstructionDataDecoder().decode(
    instruction.data!,
  );
}
