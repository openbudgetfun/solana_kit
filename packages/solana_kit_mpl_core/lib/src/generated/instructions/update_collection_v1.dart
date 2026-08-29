// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class UpdateCollectionV1InstructionData {
  const UpdateCollectionV1InstructionData({
    required this.newName,
    required this.newUri,
  }) : discriminator = 16;

  final int discriminator;
  final String? newName;
  final String? newUri;
}

Encoder<UpdateCollectionV1InstructionData>
getUpdateCollectionV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'newName',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
    (
      'newUri',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateCollectionV1InstructionData value) => <String, Object?>{
      'discriminator': 16,
      'newName': value.newName,
      'newUri': value.newUri,
    },
  );
}

Decoder<UpdateCollectionV1InstructionData>
getUpdateCollectionV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    (
      'newName',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
    (
      'newUri',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateCollectionV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateCollectionV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(16),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateCollectionV1InstructionData(
        newName: map['newName'] as String?,
        newUri: map['newUri'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateCollectionV1InstructionData>(
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
      VariableSizeDecoder<UpdateCollectionV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateCollectionV1InstructionData, UpdateCollectionV1InstructionData>
getUpdateCollectionV1InstructionDataCodec() {
  return combineCodec(
    getUpdateCollectionV1InstructionDataEncoder(),
    getUpdateCollectionV1InstructionDataDecoder(),
  );
}

/// Creates a [UpdateCollectionV1] instruction.
Instruction getUpdateCollectionV1Instruction({
  required Address programAddress,
  required Address collection,
  required Address payer,
  Address? authority,
  Address? newUpdateAuthority,
  required Address systemProgram,
  Address? logWrapper,
  required String? newName,
  required String? newUri,
}) {
  final instructionData = UpdateCollectionV1InstructionData(
    newName: newName,
    newUri: newUri,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: collection, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (newUpdateAuthority != null)
        AccountMeta(address: newUpdateAuthority, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      if (logWrapper != null)
        AccountMeta(address: logWrapper, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getUpdateCollectionV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateCollectionV1] instruction from raw instruction data.
UpdateCollectionV1InstructionData parseUpdateCollectionV1Instruction(
  Instruction instruction,
) {
  return getUpdateCollectionV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
