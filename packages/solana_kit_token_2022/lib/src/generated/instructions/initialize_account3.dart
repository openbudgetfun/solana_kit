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
class InitializeAccount3InstructionData {
  const InitializeAccount3InstructionData({
    required this.owner,
  }) : discriminator = 18;

  final int discriminator;
  final Address owner;
}

Encoder<InitializeAccount3InstructionData>
getInitializeAccount3InstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('owner', getAddressEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeAccount3InstructionData value) => <String, Object?>{
      'discriminator': 18,
      'owner': value.owner,
    },
  );
}

Decoder<InitializeAccount3InstructionData>
getInitializeAccount3InstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('owner', getAddressDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'initializeAccount3 instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeAccount3InstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(18),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeAccount3InstructionData(
        owner: map['owner']! as Address,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeAccount3InstructionData>(
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
      VariableSizeDecoder<InitializeAccount3InstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<InitializeAccount3InstructionData, InitializeAccount3InstructionData>
getInitializeAccount3InstructionDataCodec() {
  return combineCodec(
    getInitializeAccount3InstructionDataEncoder(),
    getInitializeAccount3InstructionDataDecoder(),
  );
}

/// Creates a [InitializeAccount3] instruction.
Instruction getInitializeAccount3Instruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address owner,
}) {
  final instructionData = InitializeAccount3InstructionData(
    owner: owner,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: account, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
    ],
    data: getInitializeAccount3InstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeAccount3] instruction from raw instruction data.
InitializeAccount3InstructionData parseInitializeAccount3Instruction(
  Instruction instruction,
) {
  return getInitializeAccount3InstructionDataDecoder().decode(
    instruction.data!,
  );
}
