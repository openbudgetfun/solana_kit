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
class DisableCpiGuardInstructionData {
  const DisableCpiGuardInstructionData()
    : discriminator = 34,
      cpiGuardDiscriminator = 1;

  final int discriminator;
  final int cpiGuardDiscriminator;
}

Encoder<DisableCpiGuardInstructionData>
getDisableCpiGuardInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('cpiGuardDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DisableCpiGuardInstructionData value) => <String, Object?>{
      'discriminator': 34,
      'cpiGuardDiscriminator': 1,
    },
  );
}

Decoder<DisableCpiGuardInstructionData>
getDisableCpiGuardInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('cpiGuardDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'disableCpiGuard instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DisableCpiGuardInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(34),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DisableCpiGuardInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DisableCpiGuardInstructionData>(
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
      VariableSizeDecoder<DisableCpiGuardInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<DisableCpiGuardInstructionData, DisableCpiGuardInstructionData>
getDisableCpiGuardInstructionDataCodec() {
  return combineCodec(
    getDisableCpiGuardInstructionDataEncoder(),
    getDisableCpiGuardInstructionDataDecoder(),
  );
}

/// Creates a [DisableCpiGuard] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getDisableCpiGuardInstruction({
  required Address programAddress,
  required Address token,
  required Address owner,

  bool ownerIsSigner = true,
}) {
  final instructionData = DisableCpiGuardInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getDisableCpiGuardInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [DisableCpiGuard] instruction from raw instruction data.
DisableCpiGuardInstructionData parseDisableCpiGuardInstruction(
  Instruction instruction,
) {
  return getDisableCpiGuardInstructionDataDecoder().decode(instruction.data!);
}
