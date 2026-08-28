// Auto-generated. Do not edit.
// ignore_for_file: type=lint

import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

import '../types/config_action.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class ConfigTransactionCreateInstructionData {
  ConfigTransactionCreateInstructionData({
    required this.actions,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x9b,
         0xec,
         0x57,
         0xe4,
         0x89,
         0x4b,
         0x51,
         0x27,
       ]);

  final Uint8List discriminator;
  final List<ConfigAction> actions;
  final String? memo;
}

Encoder<ConfigTransactionCreateInstructionData>
getConfigTransactionCreateInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    (
      'actions',
      getArrayEncoder<ConfigAction>(
        transformEncoder(
          getConfigActionEncoder(),
          (ConfigAction value) => value,
        ),
      ),
    ),
    (
      'memo',
      getNullableEncoder<String>(
        addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (ConfigTransactionCreateInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x9b,
        0xec,
        0x57,
        0xe4,
        0x89,
        0x4b,
        0x51,
        0x27,
      ]),
      'actions': value.actions,
      'memo': value.memo,
    },
  );
}

Decoder<ConfigTransactionCreateInstructionData>
getConfigTransactionCreateInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('actions', getArrayDecoder(getConfigActionDecoder())),
    (
      'memo',
      getNullableDecoder<String>(
        addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder()),
      ),
    ),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'configTransactionCreate instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (ConfigTransactionCreateInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x9b, 0xec, 0x57, 0xe4, 0x89, 0x4b, 0x51, 0x27]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      ConfigTransactionCreateInstructionData(
        actions: map['actions']! as List<ConfigAction>,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<ConfigTransactionCreateInstructionData>(
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
      VariableSizeDecoder<ConfigTransactionCreateInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  ConfigTransactionCreateInstructionData,
  ConfigTransactionCreateInstructionData
>
getConfigTransactionCreateInstructionDataCodec() {
  return combineCodec(
    getConfigTransactionCreateInstructionDataEncoder(),
    getConfigTransactionCreateInstructionDataDecoder(),
  );
}

/// Creates a [ConfigTransactionCreate] instruction.
Instruction getConfigTransactionCreateInstruction({
  required Address programAddress,
  required Address multisig,
  required Address transaction,
  required Address creator,
  required Address rentPayer,
  required Address systemProgram,
  required List<ConfigAction> actions,
  required String? memo,
}) {
  final instructionData = ConfigTransactionCreateInstructionData(
    actions: actions,
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.writable),
      AccountMeta(address: transaction, role: AccountRole.writable),
      AccountMeta(address: creator, role: AccountRole.readonlySigner),
      AccountMeta(address: rentPayer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getConfigTransactionCreateInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [ConfigTransactionCreate] instruction from raw instruction data.
ConfigTransactionCreateInstructionData parseConfigTransactionCreateInstruction(
  Instruction instruction,
) {
  return getConfigTransactionCreateInstructionDataDecoder().decode(
    instruction.data!,
  );
}
