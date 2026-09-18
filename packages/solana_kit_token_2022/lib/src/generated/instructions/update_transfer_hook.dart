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

/// The discriminator field name: 'transferHookDiscriminator'.
/// Offset: 1.

@immutable
class UpdateTransferHookInstructionData {
  const UpdateTransferHookInstructionData({
    required this.programId,
  }) : discriminator = 36,
       transferHookDiscriminator = 1;

  final int discriminator;
  final int transferHookDiscriminator;
  final Address? programId;
}

Encoder<UpdateTransferHookInstructionData>
getUpdateTransferHookInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferHookDiscriminator', getU8Encoder()),
    (
      'programId',
      getNullableEncoder<Address>(
        getAddressEncoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (UpdateTransferHookInstructionData value) => <String, Object?>{
      'discriminator': 36,
      'transferHookDiscriminator': 1,
      'programId': value.programId,
    },
  );
}

Decoder<UpdateTransferHookInstructionData>
getUpdateTransferHookInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferHookDiscriminator', getU8Decoder()),
    (
      'programId',
      getNullableDecoder<Address>(
        getAddressDecoder(),
        hasPrefix: false,
        noneValue: const ZeroesNoneValue(),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'updateTransferHook instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (UpdateTransferHookInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(36),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      UpdateTransferHookInstructionData(
        programId: map['programId'] as Address?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<UpdateTransferHookInstructionData>(
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
      VariableSizeDecoder<UpdateTransferHookInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<UpdateTransferHookInstructionData, UpdateTransferHookInstructionData>
getUpdateTransferHookInstructionDataCodec() {
  return combineCodec(
    getUpdateTransferHookInstructionDataEncoder(),
    getUpdateTransferHookInstructionDataDecoder(),
  );
}

/// Creates a [UpdateTransferHook] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getUpdateTransferHookInstruction({
  required Address programAddress,
  required Address mint,
  required Address authority,
  required Address? programId,
  bool authorityIsSigner = true,
}) {
  final instructionData = UpdateTransferHookInstructionData(
    programId: programId,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getUpdateTransferHookInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [UpdateTransferHook] instruction from raw instruction data.
UpdateTransferHookInstructionData parseUpdateTransferHookInstruction(
  Instruction instruction,
) {
  return getUpdateTransferHookInstructionDataDecoder().decode(
    instruction.data!,
  );
}
