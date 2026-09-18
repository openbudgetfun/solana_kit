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
class InitializeAccount2InstructionData {
  const InitializeAccount2InstructionData({
    required this.owner,
  }) : discriminator = 16;

  final int discriminator;
  final Address owner;
}

Encoder<InitializeAccount2InstructionData>
getInitializeAccount2InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('owner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeAccount2InstructionData value) => <String, Object?>{
      'discriminator': 16,
      'owner': value.owner,
    },
  );
}

Decoder<InitializeAccount2InstructionData>
getInitializeAccount2InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('owner', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeAccount2 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeAccount2InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(16),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeAccount2InstructionData(
        owner: map['owner']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeAccount2InstructionData>(
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
      VariableSizeDecoder<InitializeAccount2InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializeAccount2InstructionData, InitializeAccount2InstructionData>
getInitializeAccount2InstructionDataCodec() {
  return combineCodec(
    getInitializeAccount2InstructionDataEncoder(),
    getInitializeAccount2InstructionDataDecoder(),
  );
}

/// Creates a [InitializeAccount2] instruction.
Instruction getInitializeAccount2Instruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address rent,
  required Address owner,
}) {
  final instructionData = InitializeAccount2InstructionData(
    owner: owner,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: account, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: rent, role: AccountRole.readonly),
    ],
    data: getInitializeAccount2InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeAccount2] instruction from raw instruction data.
InitializeAccount2InstructionData parseInitializeAccount2Instruction(
  Instruction instruction,
) {
  return getInitializeAccount2InstructionDataDecoder().decode(
    instruction.data!,
  );
}
