// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class CloseEmptyTreeInstructionData {
  const CloseEmptyTreeInstructionData({this.discriminator = 6});

  final int discriminator;
}

Encoder<CloseEmptyTreeInstructionData>
getCloseEmptyTreeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CloseEmptyTreeInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
    },
  );
}

Decoder<CloseEmptyTreeInstructionData>
getCloseEmptyTreeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) =>
        CloseEmptyTreeInstructionData(
          discriminator: map['discriminator']! as int,
        ),
  );
}

Codec<CloseEmptyTreeInstructionData, CloseEmptyTreeInstructionData>
getCloseEmptyTreeInstructionDataCodec() {
  return combineCodec(
    getCloseEmptyTreeInstructionDataEncoder(),
    getCloseEmptyTreeInstructionDataDecoder(),
  );
}

/// Creates a [CloseEmptyTree] instruction.
Instruction getCloseEmptyTreeInstruction({
  required Address programAddress,
  required Address merkleTree,
  required Address authority,
  required Address recipient,
}) {
  final instructionData = CloseEmptyTreeInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: merkleTree, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: recipient, role: AccountRole.writable),
    ],
    data: getCloseEmptyTreeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CloseEmptyTree] instruction from raw instruction data.
CloseEmptyTreeInstructionData parseCloseEmptyTreeInstruction(
  Instruction instruction,
) {
  return getCloseEmptyTreeInstructionDataDecoder().decode(instruction.data!);
}
