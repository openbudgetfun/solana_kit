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
class MintToCheckedInstructionData {
  const MintToCheckedInstructionData({
    required this.amount,
    required this.decimals,
  }) : discriminator = 14;

  final int discriminator;
  final BigInt amount;
  final int decimals;
}

Encoder<MintToCheckedInstructionData> getMintToCheckedInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MintToCheckedInstructionData value) => <String, Object?>{
      'discriminator': 14,
      'amount': value.amount,
      'decimals': value.decimals,
    },
  );
}

Decoder<MintToCheckedInstructionData> getMintToCheckedInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'mintToChecked instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MintToCheckedInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(14),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MintToCheckedInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MintToCheckedInstructionData>(
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
      VariableSizeDecoder<MintToCheckedInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MintToCheckedInstructionData, MintToCheckedInstructionData>
getMintToCheckedInstructionDataCodec() {
  return combineCodec(
    getMintToCheckedInstructionDataEncoder(),
    getMintToCheckedInstructionDataDecoder(),
  );
}

/// Creates a [MintToChecked] instruction.
/// Set [mintAuthorityIsSigner] to false when [mintAuthority] does not sign (for example, a multisig authority).
Instruction getMintToCheckedInstruction({
  required Address programAddress,
  required Address mint,
  required Address token,
  required Address mintAuthority,
  required BigInt amount,
  required int decimals,
  bool mintAuthorityIsSigner = true,
}) {
  final instructionData = MintToCheckedInstructionData(
    amount: amount,
    decimals: decimals,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(
        address: mintAuthority,
        role: mintAuthorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getMintToCheckedInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MintToChecked] instruction from raw instruction data.
MintToCheckedInstructionData parseMintToCheckedInstruction(
  Instruction instruction,
) {
  return getMintToCheckedInstructionDataDecoder().decode(instruction.data!);
}
