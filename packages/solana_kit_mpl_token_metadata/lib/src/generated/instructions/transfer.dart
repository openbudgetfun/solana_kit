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

import '../types/transfer_args.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class TransferInstructionData {
  const TransferInstructionData({
    required this.transferArgs,
  }) : discriminator = 49;

  final int discriminator;
  final TransferArgs transferArgs;
}

Encoder<TransferInstructionData> getTransferInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('transferArgs', getTransferArgsEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TransferInstructionData value) => <String, Object?>{
      'discriminator': 49,
      'transferArgs': value.transferArgs,
    },
  );
}

Decoder<TransferInstructionData> getTransferInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('transferArgs', getTransferArgsDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'transfer instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (TransferInstructionData, int) readTopLevel(Uint8List bytes, int offset) {
    getConstantDecoder(
      getU8Encoder().encode(49),
    ).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      TransferInstructionData(
        transferArgs: map['transferArgs']! as TransferArgs,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TransferInstructionData>(
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
      VariableSizeDecoder<TransferInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<TransferInstructionData, TransferInstructionData>
getTransferInstructionDataCodec() {
  return combineCodec(
    getTransferInstructionDataEncoder(),
    getTransferInstructionDataDecoder(),
  );
}

/// Creates a [Transfer] instruction.
Instruction getTransferInstruction({
  required Address programAddress,
  required Address token,
  required Address tokenOwner,
  required Address destination,
  required Address destinationOwner,
  required Address mint,
  required Address metadata,
  Address? edition,
  Address? ownerTokenRecord,
  Address? destinationTokenRecord,
  required Address authority,
  required Address payer,
  required Address systemProgram,
  required Address sysvarInstructions,
  required Address splTokenProgram,
  required Address splAtaProgram,
  Address? authorizationRulesProgram,
  Address? authorizationRules,
  required TransferArgs transferArgs,
}) {
  final instructionData = TransferInstructionData(
    transferArgs: transferArgs,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: token, role: AccountRole.writable),
      AccountMeta(address: tokenOwner, role: AccountRole.readonly),
      AccountMeta(address: destination, role: AccountRole.writable),
      AccountMeta(address: destinationOwner, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.readonly),
      AccountMeta(address: metadata, role: AccountRole.writable),
      if (edition != null)
        AccountMeta(address: edition, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (ownerTokenRecord != null)
        AccountMeta(address: ownerTokenRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (destinationTokenRecord != null)
        AccountMeta(address: destinationTokenRecord, role: AccountRole.writable)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: sysvarInstructions, role: AccountRole.readonly),
      AccountMeta(address: splTokenProgram, role: AccountRole.readonly),
      AccountMeta(address: splAtaProgram, role: AccountRole.readonly),
      if (authorizationRulesProgram != null)
        AccountMeta(
          address: authorizationRulesProgram,
          role: AccountRole.readonly,
        )
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
      if (authorizationRules != null)
        AccountMeta(address: authorizationRules, role: AccountRole.readonly)
      else
        AccountMeta(address: programAddress, role: AccountRole.readonly),
    ],
    data: getTransferInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [Transfer] instruction from raw instruction data.
TransferInstructionData parseTransferInstruction(Instruction instruction) {
  return getTransferInstructionDataDecoder().decode(instruction.data!);
}
