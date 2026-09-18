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
class TransferCheckedInstructionData {
  const TransferCheckedInstructionData({
    required this.amount,
    required this.decimals,
  }) : discriminator = 12;

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<TransferCheckedInstructionData>
getTransferCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferCheckedInstructionData value) => <String, Object?>{
      'discriminator': 12,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<TransferCheckedInstructionData>
getTransferCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'transferChecked instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TransferCheckedInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(12),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      TransferCheckedInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TransferCheckedInstructionData>(
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
      VariableSizeDecoder<TransferCheckedInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<TransferCheckedInstructionData, TransferCheckedInstructionData>
getTransferCheckedInstructionDataCodec() {
  return combineCodec(
    getTransferCheckedInstructionDataEncoder(),
    getTransferCheckedInstructionDataDecoder(),
  );
}

/// Creates a [TransferChecked] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getTransferCheckedInstruction({
  required Address programAddress,
  required Address source,
  required Address mint,
  required Address destination,
  required Address authority,
  required BigInt amount,
  required int decimals,
  bool authorityIsSigner = true,
}) {
  final instructionData = TransferCheckedInstructionData(
    amount: amount,
    decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: source, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: destination, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getTransferCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TransferChecked] instruction from raw instruction data.
TransferCheckedInstructionData parseTransferCheckedInstruction(
  Instruction instruction,
) {
  return getTransferCheckedInstructionDataDecoder().decode(instruction.data!);
}
