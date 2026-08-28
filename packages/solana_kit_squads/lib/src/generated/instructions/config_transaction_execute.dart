// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ConfigTransactionExecuteInstructionData {
  ConfigTransactionExecuteInstructionData()
    : discriminator = Uint8List.fromList([
        0x72,
        0x92,
        0xf4,
        0xbd,
        0xfc,
        0x8c,
        0x24,
        0x28,
      ]);

  final Uint8List discriminator;
}

Encoder<ConfigTransactionExecuteInstructionData>
getConfigTransactionExecuteInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigTransactionExecuteInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x72,
        0x92,
        0xf4,
        0xbd,
        0xfc,
        0x8c,
        0x24,
        0x28,
      ]),
    },
  );
}

Decoder<ConfigTransactionExecuteInstructionData>
getConfigTransactionExecuteInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'configTransactionExecute instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfigTransactionExecuteInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x72, 0x92, 0xf4, 0xbd, 0xfc, 0x8c, 0x24, 0x28]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConfigTransactionExecuteInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConfigTransactionExecuteInstructionData>(
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
      VariableSizeDecoder<ConfigTransactionExecuteInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ConfigTransactionExecuteInstructionData,
  ConfigTransactionExecuteInstructionData
>
getConfigTransactionExecuteInstructionDataCodec() {
  return combineCodec(
    getConfigTransactionExecuteInstructionDataEncoder(),
    getConfigTransactionExecuteInstructionDataDecoder(),
  );
}

/// Creates a [ConfigTransactionExecute] instruction.
Instruction getConfigTransactionExecuteInstruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address proposal,
  required Address transaction,
  Address? rentPayer,
  Address? systemProgram,
}) {
  final instructionData = ConfigTransactionExecuteInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.writable),
      AccountMeta(address: member, role: AccountRole.readonlySigner),
      AccountMeta(address: proposal, role: AccountRole.writable),
      AccountMeta(address: transaction, role: AccountRole.readonly),
      if (rentPayer != null)
        AccountMeta(address: rentPayer, role: AccountRole.writableSigner)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (systemProgram != null)
        AccountMeta(address: systemProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getConfigTransactionExecuteInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ConfigTransactionExecute] instruction from raw instruction data.
ConfigTransactionExecuteInstructionData
parseConfigTransactionExecuteInstruction(Instruction instruction) {
  return getConfigTransactionExecuteInstructionDataDecoder().decode(
    instruction.data!,
  );
}
