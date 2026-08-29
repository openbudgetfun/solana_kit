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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class AddGroupsToGroupV1InstructionData {
  const AddGroupsToGroupV1InstructionData({
    required this.groups,
  }) : discriminator = 37;

  final int discriminator;
  final List<Address> groups;
}

Encoder<AddGroupsToGroupV1InstructionData>
getAddGroupsToGroupV1InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    (
      'groups',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (AddGroupsToGroupV1InstructionData value) => <String, Object?>{
      'discriminator': 37,
      'groups': value.groups,
    },
  );
}

Decoder<AddGroupsToGroupV1InstructionData>
getAddGroupsToGroupV1InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('groups', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'addGroupsToGroupV1 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (AddGroupsToGroupV1InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(37),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      AddGroupsToGroupV1InstructionData(
        groups: map['groups']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<AddGroupsToGroupV1InstructionData>(
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
      VariableSizeDecoder<AddGroupsToGroupV1InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<AddGroupsToGroupV1InstructionData, AddGroupsToGroupV1InstructionData>
getAddGroupsToGroupV1InstructionDataCodec() {
  return combineCodec(
    getAddGroupsToGroupV1InstructionDataEncoder(),
    getAddGroupsToGroupV1InstructionDataDecoder(),
  );
}

/// Creates a [AddGroupsToGroupV1] instruction.
Instruction getAddGroupsToGroupV1Instruction({
  required Address programAddress,
  required Address parentGroup,
  required Address payer,
  Address? authority,
  required Address systemProgram,
  required List<Address> groups,
}) {
  final instructionData = AddGroupsToGroupV1InstructionData(
    groups: groups,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: parentGroup, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getAddGroupsToGroupV1InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [AddGroupsToGroupV1] instruction from raw instruction data.
AddGroupsToGroupV1InstructionData parseAddGroupsToGroupV1Instruction(
  Instruction instruction,
) {
  return getAddGroupsToGroupV1InstructionDataDecoder().decode(
    instruction.data!,
  );
}
