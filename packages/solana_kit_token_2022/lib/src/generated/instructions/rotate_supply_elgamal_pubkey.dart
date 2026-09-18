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

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class RotateSupplyElgamalPubkeyInstructionData {
  const RotateSupplyElgamalPubkeyInstructionData({
    required this.newSupplyElgamalPubkey,
    required this.proofInstructionOffset,
  }) : discriminator = 42,
       confidentialMintBurnDiscriminator = 1;

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final Address newSupplyElgamalPubkey;
  final int proofInstructionOffset;
}

Encoder<RotateSupplyElgamalPubkeyInstructionData>
getRotateSupplyElgamalPubkeyInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('newSupplyElgamalPubkey', getAddressEncoder()),
    ('proofInstructionOffset', getI8Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (RotateSupplyElgamalPubkeyInstructionData value) => <String, Object?>{
      'discriminator': 42,
      'confidentialMintBurnDiscriminator': 1,
      'newSupplyElgamalPubkey': value.newSupplyElgamalPubkey,
      'proofInstructionOffset': value.proofInstructionOffset,
    },
  );
}

Decoder<RotateSupplyElgamalPubkeyInstructionData>
getRotateSupplyElgamalPubkeyInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('newSupplyElgamalPubkey', getAddressDecoder()),
    ('proofInstructionOffset', getI8Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription': 'rotateSupplyElgamalPubkey instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (RotateSupplyElgamalPubkeyInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(42),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(1),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      RotateSupplyElgamalPubkeyInstructionData(
        newSupplyElgamalPubkey: map['newSupplyElgamalPubkey']! as Address,
        proofInstructionOffset: map['proofInstructionOffset']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<RotateSupplyElgamalPubkeyInstructionData>(
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
      VariableSizeDecoder<RotateSupplyElgamalPubkeyInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  RotateSupplyElgamalPubkeyInstructionData,
  RotateSupplyElgamalPubkeyInstructionData
>
getRotateSupplyElgamalPubkeyInstructionDataCodec() {
  return combineCodec(
    getRotateSupplyElgamalPubkeyInstructionDataEncoder(),
    getRotateSupplyElgamalPubkeyInstructionDataDecoder(),
  );
}

/// Creates a [RotateSupplyElgamalPubkey] instruction.
/// Set [authorityIsSigner] to false when [authority] does not sign (for example, a multisig authority).
Instruction getRotateSupplyElgamalPubkeyInstruction({
  required Address programAddress,
  required Address mint,
  required Address instructionsSysvarOrContextState,
  required Address authority,
  required Address newSupplyElgamalPubkey,
  required int proofInstructionOffset,
  bool authorityIsSigner = true,
}) {
  final instructionData = RotateSupplyElgamalPubkeyInstructionData(
    newSupplyElgamalPubkey: newSupplyElgamalPubkey,
    proofInstructionOffset: proofInstructionOffset,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(
        address: instructionsSysvarOrContextState,
        role: AccountRole.readonly,
      ),
      AccountMeta(
        address: authority,
        role: authorityIsSigner
            ? AccountRole.readonlySigner
            : AccountRole.readonly,
      ),
    ],
    data: getRotateSupplyElgamalPubkeyInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [RotateSupplyElgamalPubkey] instruction from raw instruction data.
RotateSupplyElgamalPubkeyInstructionData
parseRotateSupplyElgamalPubkeyInstruction(Instruction instruction) {
  return getRotateSupplyElgamalPubkeyInstructionDataDecoder().decode(
    instruction.data!,
  );
}
