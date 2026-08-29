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

import '../types/update_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateCollectionInfoV1InstructionData {
  const UpdateCollectionInfoV1InstructionData({
    required this.updateType,
    required this.amount,
  }) : discriminator = 32;

  final int discriminator;
  final UpdateType updateType;
  final int amount;
}

Encoder<UpdateCollectionInfoV1InstructionData>
getUpdateCollectionInfoV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('updateType', getUpdateTypeEncoder()),
    ('amount', getU32Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateCollectionInfoV1InstructionData value) => <String, Object?>{
      'discriminator': 32,
      'updateType': value.updateType,
      'amount': value.amount,
    },
  );
}

Decoder<UpdateCollectionInfoV1InstructionData>
getUpdateCollectionInfoV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('updateType', getUpdateTypeDecoder()),
    ('amount', getU32Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateCollectionInfoV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateCollectionInfoV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(32),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateCollectionInfoV1InstructionData(
        updateType: map['updateType']! as UpdateType,
        amount: map['amount']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateCollectionInfoV1InstructionData>(
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
      VariableSizeDecoder<UpdateCollectionInfoV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  UpdateCollectionInfoV1InstructionData,
  UpdateCollectionInfoV1InstructionData
>
getUpdateCollectionInfoV1InstructionDataCodec() {
  return combineCodec(
    getUpdateCollectionInfoV1InstructionDataEncoder(),
    getUpdateCollectionInfoV1InstructionDataDecoder(),
  );
}

/// Creates a [UpdateCollectionInfoV1] instruction.
Instruction getUpdateCollectionInfoV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address bubblegumSigner,
  required UpdateType updateType,
  required int amount,
}) {
  final instructionData = UpdateCollectionInfoV1InstructionData(
    updateType: updateType,
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collection, role: AccountRole.writable),
      AccountMeta(address: bubblegumSigner, role: AccountRole.readonlySigner),
    ],
    data: getUpdateCollectionInfoV1InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [UpdateCollectionInfoV1] instruction from raw instruction data.
UpdateCollectionInfoV1InstructionData parseUpdateCollectionInfoV1Instruction(
  Instruction instruction,
) {
  return getUpdateCollectionInfoV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
