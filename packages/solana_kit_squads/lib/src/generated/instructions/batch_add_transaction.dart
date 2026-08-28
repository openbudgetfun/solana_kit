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
class BatchAddTransactionInstructionData {
  BatchAddTransactionInstructionData({
    required this.ephemeralSigners,
    required this.transactionMessage,
  }) : discriminator = Uint8List.fromList([
         0x59,
         0x64,
         0xe0,
         0x12,
         0x45,
         0x46,
         0x36,
         0x4c,
       ]);

  final Uint8List discriminator;
  final int ephemeralSigners;
  final Uint8List transactionMessage;
}

Encoder<BatchAddTransactionInstructionData>
getBatchAddTransactionInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('ephemeralSigners', getU8Encoder()),
    (
      'transactionMessage',
      addEncoderSizePrefix(getBytesEncoder(), getU32Encoder()),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (BatchAddTransactionInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x59,
        0x64,
        0xe0,
        0x12,
        0x45,
        0x46,
        0x36,
        0x4c,
      ]),
      'ephemeralSigners': value.ephemeralSigners,
      'transactionMessage': value.transactionMessage,
    },
  );
}

Decoder<BatchAddTransactionInstructionData>
getBatchAddTransactionInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('ephemeralSigners', getU8Decoder()),
    (
      'transactionMessage',
      addDecoderSizePrefix(getBytesDecoder(), getU32Decoder()),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'batchAddTransaction instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (BatchAddTransactionInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x59, 0x64, 0xe0, 0x12, 0x45, 0x46, 0x36, 0x4c]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      BatchAddTransactionInstructionData(
        ephemeralSigners: map['ephemeralSigners']! as int,
        transactionMessage: map['transactionMessage']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<BatchAddTransactionInstructionData>(
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
      VariableSizeDecoder<BatchAddTransactionInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<BatchAddTransactionInstructionData, BatchAddTransactionInstructionData>
getBatchAddTransactionInstructionDataCodec() {
  return combineCodec(
    getBatchAddTransactionInstructionDataEncoder(),
    getBatchAddTransactionInstructionDataDecoder(),
  );
}

/// Creates a [BatchAddTransaction] instruction.
Instruction getBatchAddTransactionInstruction({
  required Address programAddress,
  required Address multisig,
  required Address proposal,
  required Address batch,
  required Address transaction,
  required Address member,
  required Address rentPayer,
  required Address systemProgram,
  required int ephemeralSigners,
  required Uint8List transactionMessage,
}) {
  final instructionData = BatchAddTransactionInstructionData(
    ephemeralSigners: ephemeralSigners,
    transactionMessage: transactionMessage,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: proposal, role: AccountRole.readonly),
      AccountMeta(address: batch, role: AccountRole.writable),
      AccountMeta(address: transaction, role: AccountRole.writable),
      AccountMeta(address: member, role: AccountRole.readonlySigner),
      AccountMeta(address: rentPayer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getBatchAddTransactionInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [BatchAddTransaction] instruction from raw instruction data.
BatchAddTransactionInstructionData parseBatchAddTransactionInstruction(
  Instruction instruction,
) {
  return getBatchAddTransactionInstructionDataDecoder().decode(
    instruction.data!,
  );
}
