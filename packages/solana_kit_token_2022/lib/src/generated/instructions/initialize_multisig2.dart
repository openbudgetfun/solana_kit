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
class InitializeMultisig2InstructionData {
  const InitializeMultisig2InstructionData({
    required this.m,
  }) : discriminator = 19;

  final int discriminator;
  final int m;
}

Encoder<InitializeMultisig2InstructionData>
getInitializeMultisig2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('m', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMultisig2InstructionData value) => <String, Object?>{
      'discriminator': 19,
      'm': value.m,
    },
  );
}

Decoder<InitializeMultisig2InstructionData>
getInitializeMultisig2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('m', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeMultisig2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeMultisig2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(19),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeMultisig2InstructionData(
        m: map['m']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeMultisig2InstructionData>(
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
      VariableSizeDecoder<InitializeMultisig2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializeMultisig2InstructionData, InitializeMultisig2InstructionData>
getInitializeMultisig2InstructionDataCodec() {
  return combineCodec(
    getInitializeMultisig2InstructionDataEncoder(),
    getInitializeMultisig2InstructionDataDecoder(),
  );
}

/// Creates a [InitializeMultisig2] instruction.
Instruction getInitializeMultisig2Instruction({
  required Address programAddress,
  required Address multisig,
  required int m,
}) {
  final instructionData = InitializeMultisig2InstructionData(
    m: m,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.writable),
    ],
    data: getInitializeMultisig2InstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeMultisig2] instruction from raw instruction data.
InitializeMultisig2InstructionData parseInitializeMultisig2Instruction(
  Instruction instruction,
) {
  return getInitializeMultisig2InstructionDataDecoder().decode(
    instruction.data!,
  );
}
