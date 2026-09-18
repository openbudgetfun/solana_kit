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
class MintToInstructionData {
  const MintToInstructionData({
    required this.amount,
  }) : discriminator = 7;

  final int discriminator;
  final BigInt amount;
}

Encoder<MintToInstructionData> getMintToInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (MintToInstructionData value) => <String, Object?>{
      'discriminator': 7,
      'amount': value.amount,
    },
  );
}

Decoder<MintToInstructionData> getMintToInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'mintTo instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (MintToInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(7),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      MintToInstructionData(
        amount: map['amount']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<MintToInstructionData>(
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
      VariableSizeDecoder<MintToInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<MintToInstructionData, MintToInstructionData>
getMintToInstructionDataCodec() {
  return combineCodec(
    getMintToInstructionDataEncoder(),
    getMintToInstructionDataDecoder(),
  );
}

/// Creates a [MintTo] instruction.
/// Set [mintAuthorityIsSigner] to false when [mintAuthority] does not sign (for example, a multisig authority).
Instruction getMintToInstruction({
  required Address programAddress,
  required Address mint,
  required Address token,
  required Address mintAuthority,
  required BigInt amount,
  bool mintAuthorityIsSigner = true,
}) {
  final instructionData = MintToInstructionData(
    amount: amount,
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
    data: getMintToInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [MintTo] instruction from raw instruction data.
MintToInstructionData parseMintToInstruction(Instruction instruction) {
  return getMintToInstructionDataDecoder().decode(instruction.data!);
}
