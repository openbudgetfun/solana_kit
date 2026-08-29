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
class TransactionBufferCreateInstructionData {
  TransactionBufferCreateInstructionData({
    required this.bufferIndex,
    required this.vaultIndex,
    required this.finalBufferHash,
    required this.finalBufferSize,
    required this.buffer,
  }) : discriminator = Uint8List.fromList([
         0xf5,
         0xc9,
         0x71,
         0x6c,
         0x25,
         0x3f,
         0x1d,
         0x59,
       ]);

  final Uint8List discriminator;
  final int bufferIndex;
  final int vaultIndex;
  final Uint8List finalBufferHash;
  final int finalBufferSize;
  final Uint8List buffer;
}

Encoder<TransactionBufferCreateInstructionData>
getTransactionBufferCreateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('bufferIndex', getU8Encoder()),
    ('vaultIndex', getU8Encoder()),
    (
      'finalBufferHash',
      fixEncoderSize(getBytesEncoder(), 32, allowTruncation: false),
    ),
    ('finalBufferSize', getU16Encoder()),
    ('buffer', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (TransactionBufferCreateInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0xf5,
        0xc9,
        0x71,
        0x6c,
        0x25,
        0x3f,
        0x1d,
        0x59,
      ]),
      'bufferIndex': value.bufferIndex,
      'vaultIndex': value.vaultIndex,
      'finalBufferHash': value.finalBufferHash,
      'finalBufferSize': value.finalBufferSize,
      'buffer': value.buffer,
    },
  );
}

Decoder<TransactionBufferCreateInstructionData>
getTransactionBufferCreateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('bufferIndex', getU8Decoder()),
    ('vaultIndex', getU8Decoder()),
    ('finalBufferHash', fixDecoderSize(getBytesDecoder(), 32)),
    ('finalBufferSize', getU16Decoder()),
    ('buffer', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'transactionBufferCreate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TransactionBufferCreateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0xf5, 0xc9, 0x71, 0x6c, 0x25, 0x3f, 0x1d, 0x59]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      TransactionBufferCreateInstructionData(
        bufferIndex: map['bufferIndex']! as int,
        vaultIndex: map['vaultIndex']! as int,
        finalBufferHash: map['finalBufferHash']! as Uint8List,
        finalBufferSize: map['finalBufferSize']! as int,
        buffer: map['buffer']! as Uint8List,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TransactionBufferCreateInstructionData>(
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
      VariableSizeDecoder<TransactionBufferCreateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  TransactionBufferCreateInstructionData,
  TransactionBufferCreateInstructionData
>
getTransactionBufferCreateInstructionDataCodec() {
  return combineCodec(
    getTransactionBufferCreateInstructionDataEncoder(),
    getTransactionBufferCreateInstructionDataDecoder(),
  );
}

/// Creates a [TransactionBufferCreate] instruction.
Instruction getTransactionBufferCreateInstruction({
  required Address programAddress,
  required Address multisig,
  required Address transactionBuffer,
  required Address creator,
  required Address rentPayer,
  required Address systemProgram,
  required int bufferIndex,
  required int vaultIndex,
  required Uint8List finalBufferHash,
  required int finalBufferSize,
  required Uint8List buffer,
}) {
  final instructionData = TransactionBufferCreateInstructionData(
    bufferIndex: bufferIndex,
    vaultIndex: vaultIndex,
    finalBufferHash: finalBufferHash,
    finalBufferSize: finalBufferSize,
    buffer: buffer,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: transactionBuffer, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
      AccountMeta(address: rentPayer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getTransactionBufferCreateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [TransactionBufferCreate] instruction from raw instruction data.
TransactionBufferCreateInstructionData parseTransactionBufferCreateInstruction(
  Instruction instruction,
) {
  return getTransactionBufferCreateInstructionDataDecoder().decode(
    instruction.data!,
  );
}
