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
class InitializeMultisigInstructionData {
  const InitializeMultisigInstructionData({
    required this.m,
  }) : discriminator = 2;

  final int discriminator;
  final int m;
}

Encoder<InitializeMultisigInstructionData>
getInitializeMultisigInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('m', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeMultisigInstructionData value) => <String, Object?>{
      'discriminator': 2,
      'm': value.m,
    },
  );
}

Decoder<InitializeMultisigInstructionData>
getInitializeMultisigInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('m', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeMultisig instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeMultisigInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(2),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeMultisigInstructionData(
        m: map['m']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeMultisigInstructionData>(
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
      VariableSizeDecoder<InitializeMultisigInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializeMultisigInstructionData, InitializeMultisigInstructionData>
getInitializeMultisigInstructionDataCodec() {
  return combineCodec(
    getInitializeMultisigInstructionDataEncoder(),
    getInitializeMultisigInstructionDataDecoder(),
  );
}

/// Creates a [InitializeMultisig] instruction.
Instruction getInitializeMultisigInstruction({
  required Address programAddress,
  required Address multisig,
  required Address rent,
  required int m,
}) {
  final instructionData = InitializeMultisigInstructionData(
    m: m,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.writable),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getInitializeMultisigInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeMultisig] instruction from raw instruction data.
InitializeMultisigInstructionData parseInitializeMultisigInstruction(
  Instruction instruction,
) {
  return getInitializeMultisigInstructionDataDecoder().decode(
    instruction.data!,
  );
}
