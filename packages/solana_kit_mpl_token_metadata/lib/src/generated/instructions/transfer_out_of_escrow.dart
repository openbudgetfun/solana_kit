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
class TransferOutOfEscrowInstructionData {
  const TransferOutOfEscrowInstructionData({
    required this.amount,
  }) : discriminator = 40;

  final int discriminator;
  final BigInt amount;
}

Encoder<TransferOutOfEscrowInstructionData>
getTransferOutOfEscrowInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('amount', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferOutOfEscrowInstructionData value) => <String, Object?>{
      'discriminator': 40,
      'amount': value.amount,
    },
  );
}

Decoder<TransferOutOfEscrowInstructionData>
getTransferOutOfEscrowInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('amount', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'transferOutOfEscrow instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TransferOutOfEscrowInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(40),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      TransferOutOfEscrowInstructionData(
        amount: map['amount']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TransferOutOfEscrowInstructionData>(
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
      VariableSizeDecoder<TransferOutOfEscrowInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<TransferOutOfEscrowInstructionData, TransferOutOfEscrowInstructionData>
getTransferOutOfEscrowInstructionDataCodec() {
  return combineCodec(
    getTransferOutOfEscrowInstructionDataEncoder(),
    getTransferOutOfEscrowInstructionDataDecoder(),
  );
}

/// Creates a [TransferOutOfEscrow] instruction.
Instruction getTransferOutOfEscrowInstruction({
  required Address programAddress,
  required Address escrow,
  required Address metadata,
  required Address payer,
  required Address attributeMint,
  required Address attributeSrc,
  required Address attributeDst,
  required Address escrowMint,
  required Address escrowAccount,
  required Address systemProgram,
  required Address ataProgram,
  required Address tokenProgram,
  required Address sysvarInstructions,
  Address? authority,
  required BigInt amount,
}) {
  final instructionData = TransferOutOfEscrowInstructionData(
    amount: amount,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: escrow, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: attributeMint, role: AccountRole.readonly),
      AccountMeta(address: attributeSrc, role: AccountRole.writable),
      AccountMeta(address: attributeDst, role: AccountRole.writable),
      AccountMeta(address: escrowMint, role: AccountRole.readonly),
      AccountMeta(address: escrowAccount, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: ataProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      if (authority != null)
        AccountMeta(address: authority, role: AccountRole.readonlySigner),
    ],
    data: getTransferOutOfEscrowInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [TransferOutOfEscrow] instruction from raw instruction data.
TransferOutOfEscrowInstructionData parseTransferOutOfEscrowInstruction(
  Instruction instruction,
) {
  return getTransferOutOfEscrowInstructionDataDecoder().decode(
    instruction.data!,
  );
}
