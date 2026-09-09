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
class CreateSchemaInstructionData {
  const CreateSchemaInstructionData({
    required this.name,
    required this.description,
    required this.layout,
    required this.fieldNames,
  }) : discriminator = 1;

  final int discriminator;
  final String name;
  final String description;
  final List<SchemaDataType> layout;
  final List<String> fieldNames;
}

Encoder<CreateSchemaInstructionData> getCreateSchemaInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('description', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
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
    (CreateSchemaInstructionData value) => <String, Object?>{
      'discriminator': 1,
      'name': value.name,
      'description': value.description,
      'layout': value.layout,
      'fieldNames': value.fieldNames,
    },
  );
}

Decoder<CreateSchemaInstructionData> getCreateSchemaInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('description', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('layout', getArrayDecoder(getSchemaDataTypeDecoder())),
    (
      'fieldNames',
      getArrayDecoder(addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'createSchema instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (CreateSchemaInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(getU8Encoder().encode(1)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateSchemaInstructionData(
        name: map['name']! as String,
        description: map['description']! as String,
        layout: map['layout']! as List<SchemaDataType>,
        fieldNames: map['fieldNames']! as List<String>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateSchemaInstructionData>(
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
      VariableSizeDecoder<CreateSchemaInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateSchemaInstructionData, CreateSchemaInstructionData>
getCreateSchemaInstructionDataCodec() {
  return combineCodec(
    getCreateSchemaInstructionDataEncoder(),
    getCreateSchemaInstructionDataDecoder(),
  );
}

/// Creates a [CreateSchema] instruction.
Instruction getCreateSchemaInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address schema,
  required Address systemProgram,
  required String name,
  required String description,
  required List<SchemaDataType> layout,
  required List<String> fieldNames,
}) {
  final instructionData = CreateSchemaInstructionData(
    name: name,
    description: description,
    layout: layout,
    fieldNames: fieldNames,
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
    data: getCreateSchemaInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateSchema] instruction from raw instruction data.
CreateSchemaInstructionData parseCreateSchemaInstruction(
  Instruction instruction,
) {
  return getCreateSchemaInstructionDataDecoder().decode(instruction.data!);
}
