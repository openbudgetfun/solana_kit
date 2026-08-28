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
class ConfigTransactionAccountsCloseInstructionData {
  ConfigTransactionAccountsCloseInstructionData()
    : discriminator = Uint8List.fromList([
        0x50,
        0xcb,
        0x54,
        0x35,
        0x97,
        0x70,
        0xbb,
        0xba,
      ]);

  final Uint8List discriminator;
}

Encoder<ConfigTransactionAccountsCloseInstructionData>
getConfigTransactionAccountsCloseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigTransactionAccountsCloseInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x50,
        0xcb,
        0x54,
        0x35,
        0x97,
        0x70,
        0xbb,
        0xba,
      ]),
    },
  );
}

Decoder<ConfigTransactionAccountsCloseInstructionData>
getConfigTransactionAccountsCloseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'configTransactionAccountsClose instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfigTransactionAccountsCloseInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x50, 0xcb, 0x54, 0x35, 0x97, 0x70, 0xbb, 0xba]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConfigTransactionAccountsCloseInstructionData(),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConfigTransactionAccountsCloseInstructionData>(
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
      VariableSizeDecoder<ConfigTransactionAccountsCloseInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ConfigTransactionAccountsCloseInstructionData,
  ConfigTransactionAccountsCloseInstructionData
>
getConfigTransactionAccountsCloseInstructionDataCodec() {
  return combineCodec(
    getConfigTransactionAccountsCloseInstructionDataEncoder(),
    getConfigTransactionAccountsCloseInstructionDataDecoder(),
  );
}

/// Creates a [ConfigTransactionAccountsClose] instruction.
Instruction getConfigTransactionAccountsCloseInstruction({
  required Address programAddress,
  required Address multisig,
  required Address proposal,
  required Address transaction,
  required Address rentCollector,
  required Address systemProgram,
}) {
  final instructionData = ConfigTransactionAccountsCloseInstructionData();

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: proposal, role: AccountRole.writable),
      AccountMeta(address: transaction, role: AccountRole.writable),
      AccountMeta(address: rentCollector, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getConfigTransactionAccountsCloseInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ConfigTransactionAccountsClose] instruction from raw instruction data.
ConfigTransactionAccountsCloseInstructionData
parseConfigTransactionAccountsCloseInstruction(Instruction instruction) {
  return getConfigTransactionAccountsCloseInstructionDataDecoder().decode(
    instruction.data!,
  );
}
