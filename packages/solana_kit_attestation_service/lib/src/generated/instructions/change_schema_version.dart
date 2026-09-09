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

import '../types/schema_data_type.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ChangeSchemaVersionInstructionData {
  const ChangeSchemaVersionInstructionData({
    required this.layout,
    required this.fieldNames,
  }) : discriminator = 5;

  final int discriminator;
  final List<SchemaDataType> layout;
  final List<String> fieldNames;
}

Encoder<ChangeSchemaVersionInstructionData>
getChangeSchemaVersionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'layout',
      getArrayEncoder(
        transformEncoder(
          getSchemaDataTypeEncoder(),
          (SchemaDataType value) => value,
        ),
      ),
    ),
    (
      'fieldNames',
      getArrayEncoder(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ChangeSchemaVersionInstructionData value) => <String, Object?>{
      'discriminator': 5,
      'layout': value.layout,
      'fieldNames': value.fieldNames,
    },
  );
}

Decoder<ChangeSchemaVersionInstructionData>
getChangeSchemaVersionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('layout', getArrayDecoder(getSchemaDataTypeDecoder())),
    (
      'fieldNames',
      getArrayDecoder(addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'changeSchemaVersion instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (ChangeSchemaVersionInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(5)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ChangeSchemaVersionInstructionData(
        layout: map['layout']! as List<SchemaDataType>,
        fieldNames: map['fieldNames']! as List<String>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ChangeSchemaVersionInstructionData>(
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
      VariableSizeDecoder<ChangeSchemaVersionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ChangeSchemaVersionInstructionData, ChangeSchemaVersionInstructionData>
getChangeSchemaVersionInstructionDataCodec() {
  return combineCodec(
    getChangeSchemaVersionInstructionDataEncoder(),
    getChangeSchemaVersionInstructionDataDecoder(),
  );
}

/// Creates a [ChangeSchemaVersion] instruction.
Instruction getChangeSchemaVersionInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address existingSchema,
  required Address newSchema,
  required Address systemProgram,
  required List<SchemaDataType> layout,
  required List<String> fieldNames,
}) {
  final instructionData = ChangeSchemaVersionInstructionData(
    layout: layout,
    fieldNames: fieldNames,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: credential, role: AccountRole.readonly),
      AccountMeta(address: existingSchema, role: AccountRole.readonly),
      AccountMeta(address: newSchema, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getChangeSchemaVersionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ChangeSchemaVersion] instruction from raw instruction data.
ChangeSchemaVersionInstructionData parseChangeSchemaVersionInstruction(
  Instruction instruction,
) {
  return getChangeSchemaVersionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
