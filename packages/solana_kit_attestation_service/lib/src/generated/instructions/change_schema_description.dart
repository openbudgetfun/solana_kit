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
class ChangeSchemaDescriptionInstructionData {
  const ChangeSchemaDescriptionInstructionData({required this.description})
    : discriminator = 4;

  final int discriminator;
  final String description;
}

Encoder<ChangeSchemaDescriptionInstructionData>
getChangeSchemaDescriptionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('description', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (ChangeSchemaDescriptionInstructionData value) => <String, Object?>{
      'discriminator': 4,
      'description': value.description,
    },
  );
}

Decoder<ChangeSchemaDescriptionInstructionData>
getChangeSchemaDescriptionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('description', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'changeSchemaDescription instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (ChangeSchemaDescriptionInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(4)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ChangeSchemaDescriptionInstructionData(
        description: map['description']! as String,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ChangeSchemaDescriptionInstructionData>(
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
      VariableSizeDecoder<ChangeSchemaDescriptionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ChangeSchemaDescriptionInstructionData,
  ChangeSchemaDescriptionInstructionData
>
getChangeSchemaDescriptionInstructionDataCodec() {
  return combineCodec(
    getChangeSchemaDescriptionInstructionDataEncoder(),
    getChangeSchemaDescriptionInstructionDataDecoder(),
  );
}

/// Creates a [ChangeSchemaDescription] instruction.
Instruction getChangeSchemaDescriptionInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address schema,
  required Address systemProgram,
  required String description,
}) {
  final instructionData = ChangeSchemaDescriptionInstructionData(
    description: description,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: credential, role: AccountRole.readonly),
      AccountMeta(address: schema, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getChangeSchemaDescriptionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ChangeSchemaDescription] instruction from raw instruction data.
ChangeSchemaDescriptionInstructionData parseChangeSchemaDescriptionInstruction(
  Instruction instruction,
) {
  return getChangeSchemaDescriptionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
