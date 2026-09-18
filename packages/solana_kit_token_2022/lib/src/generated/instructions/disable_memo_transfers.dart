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

/// The discriminator field name: 'memoTransfersDiscriminator'.
/// Offset: 1.

@immutable
class DisableMemoTransfersInstructionData {
  const DisableMemoTransfersInstructionData()
    : discriminator = 30,
      memoTransfersDiscriminator = 1;

  final int discriminator;
  final int memoTransfersDiscriminator;
}

Encoder<DisableMemoTransfersInstructionData>
getDisableMemoTransfersInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('memoTransfersDiscriminator', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (DisableMemoTransfersInstructionData value) => <String, Object?>{
      'discriminator': 30,
      'memoTransfersDiscriminator': 1,
    },
  );
}

Decoder<DisableMemoTransfersInstructionData>
getDisableMemoTransfersInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('memoTransfersDiscriminator', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'disableMemoTransfers instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (DisableMemoTransfersInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(30),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      DisableMemoTransfersInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<DisableMemoTransfersInstructionData>(
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
      VariableSizeDecoder<DisableMemoTransfersInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<DisableMemoTransfersInstructionData, DisableMemoTransfersInstructionData>
getDisableMemoTransfersInstructionDataCodec() {
  return combineCodec(
    getDisableMemoTransfersInstructionDataEncoder(),
    getDisableMemoTransfersInstructionDataDecoder(),
  );
}

/// Creates a [DisableMemoTransfers] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getDisableMemoTransfersInstruction({
  required Address programAddress,
  required Address token,
  required Address owner,

  bool ownerIsSigner = true,
}) {
  final instructionData = DisableMemoTransfersInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getDisableMemoTransfersInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [DisableMemoTransfers] instruction from raw instruction data.
DisableMemoTransfersInstructionData parseDisableMemoTransfersInstruction(
  Instruction instruction,
) {
  return getDisableMemoTransfersInstructionDataDecoder().decode(
    instruction.data!,
  );
}
