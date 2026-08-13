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
class WriteInstructionData {
  const WriteInstructionData({
    this.discriminator = 1,
    required this.offset,
    required this.bytes,
  });

  final int discriminator;
  final int offset;
  final Uint8List bytes;
}

Encoder<WriteInstructionData> getWriteInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU32Encoder()),
    ('offset', getU32Encoder()),
    ('bytes', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (WriteInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'offset': value.offset,
      'bytes': value.bytes,
    },
  );
}

Decoder<WriteInstructionData> getWriteInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU32Decoder()),
    ('offset', getU32Decoder()),
    ('bytes', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => WriteInstructionData(
      discriminator: map['discriminator']! as int,
      offset: map['offset']! as int,
      bytes: map['bytes']! as Uint8List,
    ),
  );
}

Codec<WriteInstructionData, WriteInstructionData> getWriteInstructionDataCodec() {
  return combineCodec(getWriteInstructionDataEncoder(), getWriteInstructionDataDecoder());
}

/// Creates a [Write] instruction.
Instruction getWriteInstruction({
  required Address programAddress,
  required Address bufferAccount,
  required Address bufferAuthority,
  required int offset,
  required Uint8List bytes,
}) {
  final instructionData = WriteInstructionData(
      offset: offset,
      bytes: bytes,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: bufferAccount, role: AccountRole.writable),
    AccountMeta(address: bufferAuthority, role: AccountRole.readonlySigner),
    ],
    data: getWriteInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Write] instruction from raw instruction data.
WriteInstructionData parseWriteInstruction(Instruction instruction) {
  return getWriteInstructionDataDecoder().decode(instruction.data!);
}
