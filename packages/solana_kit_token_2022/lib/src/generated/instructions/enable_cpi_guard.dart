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

/// The discriminator field name: 'cpiGuardDiscriminator'.
/// Offset: 1.

@immutable
class EnableCpiGuardInstructionData {
  const EnableCpiGuardInstructionData()
    : discriminator = 34,
      cpiGuardDiscriminator = 0;

  final int discriminator;
  final int cpiGuardDiscriminator;
}

Encoder<EnableCpiGuardInstructionData>
getEnableCpiGuardInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('cpiGuardDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (EnableCpiGuardInstructionData value) => <String, Object?>{
      'discriminator': 34,
      'cpiGuardDiscriminator': 0,
    },
  );
}

Decoder<EnableCpiGuardInstructionData>
getEnableCpiGuardInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('cpiGuardDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'enableCpiGuard instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (EnableCpiGuardInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(34),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      EnableCpiGuardInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<EnableCpiGuardInstructionData>(
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
      VariableSizeDecoder<EnableCpiGuardInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<EnableCpiGuardInstructionData, EnableCpiGuardInstructionData>
getEnableCpiGuardInstructionDataCodec() {
  return combineCodec(
    getEnableCpiGuardInstructionDataEncoder(),
    getEnableCpiGuardInstructionDataDecoder(),
  );
}

/// Creates a [EnableCpiGuard] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getEnableCpiGuardInstruction({
  required Address programAddress,
  required Address token,
  required Address owner,

  bool ownerIsSigner = true,
}) {
  final instructionData = EnableCpiGuardInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getEnableCpiGuardInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [EnableCpiGuard] instruction from raw instruction data.
EnableCpiGuardInstructionData parseEnableCpiGuardInstruction(
  Instruction instruction,
) {
  return getEnableCpiGuardInstructionDataDecoder().decode(instruction.data!);
}
