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

import '../types/relationship_entry.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CreateGroupV1InstructionData {
  const CreateGroupV1InstructionData({
    required this.name,
    required this.uri,
    required this.relationships,
  }) : discriminator = 39;

  final int discriminator;
  final String name;
  final String uri;
  final List<RelationshipEntry> relationships;
}

Encoder<CreateGroupV1InstructionData> getCreateGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    (
      'relationships',
      getArrayEncoder(
        transformEncoder(
          getRelationshipEntryEncoder(),
          (RelationshipEntry value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 39,
      'name': value.name,
      'uri': value.uri,
      'relationships': value.relationships,
    },
  );
}

Decoder<CreateGroupV1InstructionData> getCreateGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('relationships', getArrayDecoder(getRelationshipEntryDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'createGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (CreateGroupV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(39),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateGroupV1InstructionData(
        name: map['name']! as String,
        uri: map['uri']! as String,
        relationships: map['relationships']! as List<RelationshipEntry>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateGroupV1InstructionData>(
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
      VariableSizeDecoder<CreateGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateGroupV1InstructionData, CreateGroupV1InstructionData>
getCreateGroupV1InstructionDataCodec() {
  return combineCodec(
    getCreateGroupV1InstructionDataEncoder(),
    getCreateGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [CreateGroupV1] instruction.
Instruction getCreateGroupV1Instruction({
  required Address programAddress,
  required Address group,
  Address? updateAuthority,
  required Address payer,
  required Address systemProgram,
  required String name,
  required String uri,
  required List<RelationshipEntry> relationships,
}) {
  final instructionData = CreateGroupV1InstructionData(
    name: name,
    uri: uri,
    relationships: relationships,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: group, role: AccountRole.writableSigner),
      if (updateAuthority != null)
        AccountMeta(address: updateAuthority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateGroupV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateGroupV1] instruction from raw instruction data.
CreateGroupV1InstructionData parseCreateGroupV1Instruction(
  Instruction instruction,
) {
  return getCreateGroupV1InstructionDataDecoder().decode(instruction.data!);
}
