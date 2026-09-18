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
class BurnCheckedInstructionData {
  const BurnCheckedInstructionData({
    required this.amount,
    required this.decimals,
  }) : discriminator = 15;

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<BurnCheckedInstructionData> getBurnCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (BurnCheckedInstructionData value) => <String, Object?>{
      'discriminator': 15,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<BurnCheckedInstructionData> getBurnCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'burnChecked instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BurnCheckedInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(15),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BurnCheckedInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BurnCheckedInstructionData>(
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
      VariableSizeDecoder<BurnCheckedInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BurnCheckedInstructionData, BurnCheckedInstructionData>
getBurnCheckedInstructionDataCodec() {
  return combineCodec(
    getBurnCheckedInstructionDataEncoder(),
    getBurnCheckedInstructionDataDecoder(),
  );
}

/// Creates a [BurnChecked] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getBurnCheckedInstruction({
  required Address programAddress,
  required Address account,
  required Address mint,
  required Address authority,
  required BigInt amount,
  required int decimals,
  bool authorityIsSigner = true,
}) {
  final instructionData = BurnCheckedInstructionData(
    amount: amount,
    decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: account, role: AccountRole.writable),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getBurnCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [BurnChecked] instruction from raw instruction data.
BurnCheckedInstructionData parseBurnCheckedInstruction(
  Instruction instruction,
) {
  return getBurnCheckedInstructionDataDecoder().decode(instruction.data!);
}
