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

/// The discriminator field name: 'transferFeeDiscriminator'.
/// Offset: 1.

@immutable
class SetTransferFeeInstructionData {
  const SetTransferFeeInstructionData({
    required this.transferFeeBasisPoints,
    required this.maximumFee,
  }) : discriminator = 26,
       transferFeeDiscriminator = 5;

  final int discriminator;
  final int transferFeeDiscriminator;
  final int transferFeeBasisPoints;
  final BigInt maximumFee;
}

Encoder<SetTransferFeeInstructionData>
getSetTransferFeeInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferFeeDiscriminator', getU8Encoder()),
    ('transferFeeBasisPoints', getU16Encoder()),
    ('maximumFee', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (SetTransferFeeInstructionData value) => <String, Object?>{
      'discriminator': 26,
      'transferFeeDiscriminator': 5,
      'transferFeeBasisPoints': value.transferFeeBasisPoints,
      'maximumFee': value.maximumFee,
    },
  );
}

Decoder<SetTransferFeeInstructionData>
getSetTransferFeeInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferFeeDiscriminator', getU8Decoder()),
    ('transferFeeBasisPoints', getU16Decoder()),
    ('maximumFee', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'setTransferFee instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SetTransferFeeInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(26),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(5),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      SetTransferFeeInstructionData(
        transferFeeBasisPoints: map['transferFeeBasisPoints']! as int,
        maximumFee: map['maximumFee']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SetTransferFeeInstructionData>(
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
      VariableSizeDecoder<SetTransferFeeInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SetTransferFeeInstructionData, SetTransferFeeInstructionData>
getSetTransferFeeInstructionDataCodec() {
  return combineCodec(
    getSetTransferFeeInstructionDataEncoder(),
    getSetTransferFeeInstructionDataDecoder(),
  );
}

/// Creates a [SetTransferFee] instruction.
/// Set [transferFeeConfigAuthorityIsSigner] to false when [transferFeeConfigAuthority] does not sign (for example, a multisig authority).
Instruction getSetTransferFeeInstruction({
  required Address programAddress,
  required Address mint,
  required Address transferFeeConfigAuthority,
  required int transferFeeBasisPoints,
  required BigInt maximumFee,
  bool transferFeeConfigAuthorityIsSigner = true,
}) {
  final instructionData = SetTransferFeeInstructionData(
    transferFeeBasisPoints: transferFeeBasisPoints,
    maximumFee: maximumFee,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: transferFeeConfigAuthority,
        role: transferFeeConfigAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getSetTransferFeeInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SetTransferFee] instruction from raw instruction data.
SetTransferFeeInstructionData parseSetTransferFeeInstruction(
  Instruction instruction,
) {
  return getSetTransferFeeInstructionDataDecoder().decode(instruction.data!);
}
