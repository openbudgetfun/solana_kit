// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

@immutable
class CreateTreeInstructionData {
  const CreateTreeInstructionData({
    this.discriminator = 6,
    required this.maxDepth,
    required this.maxBufferSize,
    required this.isPublic,
  });

  final int discriminator;
  final int maxDepth;
  final int maxBufferSize;
  final bool isPublic;
}

Encoder<CreateTreeInstructionData> getCreateTreeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('maxDepth', getU32Encoder()),
    ('maxBufferSize', getU32Encoder()),
    ('isPublic', getBooleanEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateTreeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'maxDepth': value.maxDepth,
      'maxBufferSize': value.maxBufferSize,
      'isPublic': value.isPublic,
    },
  );
}

Decoder<CreateTreeInstructionData> getCreateTreeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('maxDepth', getU32Decoder()),
    ('maxBufferSize', getU32Decoder()),
    ('isPublic', getBooleanDecoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CreateTreeInstructionData(
          discriminator: map['discriminator']! as int,
          maxDepth: map['maxDepth']! as int,
          maxBufferSize: map['maxBufferSize']! as int,
          isPublic: map['isPublic']! as bool,
        ),
  );
}

Codec<CreateTreeInstructionData, CreateTreeInstructionData>
    getCreateTreeInstructionDataCodec() {
  return combineCodec(
    getCreateTreeInstructionDataEncoder(),
    getCreateTreeInstructionDataDecoder(),
  );
}

/// Creates a [CreateTree] instruction.
///
/// This instruction initializes a new Merkle tree with the specified
/// depth, buffer size, and public/private visibility.
Instruction getCreateTreeInstruction({
  required Address programAddress,
  required Address treeAuthority,
  required Address merkleTree,
  required Address payer,
  required Address treeCreator,
  required Address logWrapper,
  required Address compressionProgram,
  required Address systemProgram,
  required int maxDepth,
  required int maxBufferSize,
  required bool isPublic,
}) {
  final instructionData = CreateTreeInstructionData(
    maxDepth: maxDepth,
    maxBufferSize: maxBufferSize,
    isPublic: isPublic,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: treeAuthority, role: AccountRole.writable),
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: treeCreator, role: AccountRole.readonlySigner),
      AccountMeta(address: logWrapper, role: AccountRole.readonly),
      AccountMeta(address: compressionProgram, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateTreeInstructionDataEncoder().encode(instructionData),
  );
}