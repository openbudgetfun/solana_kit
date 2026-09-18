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
class ApproveCheckedInstructionData {
  const ApproveCheckedInstructionData({
    required this.amount,
    required this.decimals,
  }) : discriminator = 13;

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<ApproveCheckedInstructionData>
getApproveCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (ApproveCheckedInstructionData value) => <String, Object?>{
      'discriminator': 13,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<ApproveCheckedInstructionData>
getApproveCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'approveChecked instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ApproveCheckedInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(13),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ApproveCheckedInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ApproveCheckedInstructionData>(
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
      VariableSizeDecoder<ApproveCheckedInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<ApproveCheckedInstructionData, ApproveCheckedInstructionData>
getApproveCheckedInstructionDataCodec() {
  return combineCodec(
    getApproveCheckedInstructionDataEncoder(),
    getApproveCheckedInstructionDataDecoder(),
  );
}

/// Creates a [ApproveChecked] instruction.
/// Set [ownerIsSigner] to false when [owner] does not sign (for example, a multisig authority).
Instruction getApproveCheckedInstruction({
  required Address programAddress,
  required Address source,
  required Address mint,
  required Address delegate,
  required Address owner,
  required BigInt amount,
  required int decimals,
  bool ownerIsSigner = true,
}) {
  final instructionData = ApproveCheckedInstructionData(
    amount: amount,
    decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: source, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: delegate, role: AccountRole.readonly),
      AccountMeta(
        address: owner,
        role: ownerIsSigner ? AccountRole.readonlySigner : AccountRole.readonly,
      ),
    ],
    data: getApproveCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [ApproveChecked] instruction from raw instruction data.
ApproveCheckedInstructionData parseApproveCheckedInstruction(
  Instruction instruction,
) {
  return getApproveCheckedInstructionDataDecoder().decode(instruction.data!);
}
