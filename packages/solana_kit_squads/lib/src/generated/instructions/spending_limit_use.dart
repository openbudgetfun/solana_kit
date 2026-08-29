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

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class SpendingLimitUseInstructionData {
  SpendingLimitUseInstructionData({
    required this.amount,
    required this.decimals,
    required this.memo,
  }) : discriminator = Uint8List.fromList([
         0x10,
         0x39,
         0x82,
         0x7f,
         0xc1,
         0x14,
         0x9b,
         0x86,
       ]);

  final Uint8List discriminator;
  final BigInt amount;
  final int decimals;
  final String? memo;
}

Encoder<SpendingLimitUseInstructionData>
getSpendingLimitUseInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    (
      'discriminator',
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false),
    ),
    ('amount', getU64Encoder()),
    ('decimals', getU8Encoder()),
    (
      'memo',
      getNullableEncoder<String>(
        transformEncoder(
          addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder()),
          (String value) => value,
        ),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (SpendingLimitUseInstructionData value) => <String, Object?>{
      'discriminator': Uint8List.fromList([
        0x10,
        0x39,
        0x82,
        0x7f,
        0xc1,
        0x14,
        0x9b,
        0x86,
      ]),
      'amount': value.amount,
      'decimals': value.decimals,
      'memo': value.memo,
    },
  );
}

Decoder<SpendingLimitUseInstructionData>
getSpendingLimitUseInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', fixDecoderSize(getBytesDecoder(), 8)),
    ('amount', getU64Decoder()),
    ('decimals', getU8Decoder()),
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
        'codecDescription': 'spendingLimitUse instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (SpendingLimitUseInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      fixEncoderSize(getBytesEncoder(), 8, allowTruncation: false).encode(
        Uint8List.fromList([0x10, 0x39, 0x82, 0x7f, 0xc1, 0x14, 0x9b, 0x86]),
      ),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      SpendingLimitUseInstructionData(
        amount: map['amount']! as BigInt,
        decimals: map['decimals']! as int,
        memo: map['memo'] as String?,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<SpendingLimitUseInstructionData>(
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
      VariableSizeDecoder<SpendingLimitUseInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<SpendingLimitUseInstructionData, SpendingLimitUseInstructionData>
getSpendingLimitUseInstructionDataCodec() {
  return combineCodec(
    getSpendingLimitUseInstructionDataEncoder(),
    getSpendingLimitUseInstructionDataDecoder(),
  );
}

/// Creates a [SpendingLimitUse] instruction.
Instruction getSpendingLimitUseInstruction({
  required Address programAddress,
  required Address multisig,
  required Address member,
  required Address spendingLimit,
  required Address vault,
  required Address destination,
  Address? systemProgram,
  Address? mint,
  Address? vaultTokenAccount,
  Address? destinationTokenAccount,
  Address? tokenProgram,
  required BigInt amount,
  required int decimals,
  required String? memo,
}) {
  final instructionData = SpendingLimitUseInstructionData(
    amount: amount,
    decimals: decimals,
    memo: memo,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: multisig, role: AccountRole.readonly),
      AccountMeta(address: member, role: AccountRole.readonlySigner),
      AccountMeta(address: spendingLimit, role: AccountRole.writable),
      AccountMeta(address: vault, role: AccountRole.writable),
      AccountMeta(address: destination, role: AccountRole.writable),
      if (systemProgram != null)
        AccountMeta(address: systemProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (mint != null)
        AccountMeta(address: mint, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (vaultTokenAccount != null)
        AccountMeta(address: vaultTokenAccount, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (destinationTokenAccount != null)
        AccountMeta(
          address: destinationTokenAccount,
          role: AccountRole.writable,
        )
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (tokenProgram != null)
        AccountMeta(address: tokenProgram, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getSpendingLimitUseInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [SpendingLimitUse] instruction from raw instruction data.
SpendingLimitUseInstructionData parseSpendingLimitUseInstruction(
  Instruction instruction,
) {
  return getSpendingLimitUseInstructionDataDecoder().decode(instruction.data!);
}
