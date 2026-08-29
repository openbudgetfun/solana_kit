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

/// This instruction has a size discriminator of 3 bytes.

@immutable
class SecureActionInstructionData {
  const SecureActionInstructionData({
    required this.amount,
  }) :
      discriminator = 9;

  final int discriminator;
  final int amount;
}

Encoder<SecureActionInstructionData> getSecureActionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SecureActionInstructionData value) => <String, Object?>{
      'discriminator': 9,
      'amount': value.amount,
    },
  );
}

Decoder<SecureActionInstructionData> getSecureActionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU16Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'secureAction instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SecureActionInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(9),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(9),
    ).read(bytes, offset + 0);
    if (bytes.length - offset != 3) {
      throw SolanaError(
        SolanaErrorCode.codecsInvalidByteLength,
        {
          'codecDescription': 'secureAction discriminator',
          'expected': 3,
          'bytesLength': bytes.length - offset,
        },
      );
    }
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      SecureActionInstructionData(
      amount: map['amount']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SecureActionInstructionData>(
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
      VariableSizeDecoder<SecureActionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SecureActionInstructionData, SecureActionInstructionData> getSecureActionInstructionDataCodec() {
  return combineCodec(getSecureActionInstructionDataEncoder(), getSecureActionInstructionDataDecoder());
}

/// Creates a [SecureAction] instruction.
Instruction getSecureActionInstruction({
  required Address programAddress,
  required Address before,
  Address? optionalMiddle,
  required Address after,
  required int amount,
}) {
  final instructionData = SecureActionInstructionData(
      amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: before, role: AccountRole.readonly),
    if (optionalMiddle != null) AccountMeta(address: optionalMiddle, role: AccountRole.writable) else AccountMeta(address: programAddress, role: AccountRole.readonly),
    AccountMeta(address: after, role: AccountRole.readonlySigner),
    ],
    data: getSecureActionInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SecureAction] instruction from raw instruction data.
SecureActionInstructionData parseSecureActionInstruction(Instruction instruction) {
  return getSecureActionInstructionDataDecoder().decode(instruction.data!);
}
