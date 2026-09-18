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

import '../types/decryptable_balance.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

/// The discriminator field name: 'confidentialMintBurnDiscriminator'.
/// Offset: 1.

@immutable
class InitializeConfidentialMintBurnInstructionData {
  const InitializeConfidentialMintBurnInstructionData({
    required this.supplyElgamalPubkey,
    required this.decryptableSupply,
  }) : discriminator = 42,
       confidentialMintBurnDiscriminator = 0;

  final int discriminator;
  final int confidentialMintBurnDiscriminator;
  final Address supplyElgamalPubkey;
  final DecryptableBalance decryptableSupply;
}

Encoder<InitializeConfidentialMintBurnInstructionData>
getInitializeConfidentialMintBurnInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('confidentialMintBurnDiscriminator', getU8Encoder()),
    ('supplyElgamalPubkey', getAddressEncoder()),
    ('decryptableSupply', getDecryptableBalanceEncoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeConfidentialMintBurnInstructionData value) => <String, Object?>{
      'discriminator': 42,
      'confidentialMintBurnDiscriminator': 0,
      'supplyElgamalPubkey': value.supplyElgamalPubkey,
      'decryptableSupply': value.decryptableSupply,
    },
  );
}

Decoder<InitializeConfidentialMintBurnInstructionData>
getInitializeConfidentialMintBurnInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('confidentialMintBurnDiscriminator', getU8Decoder()),
    ('supplyElgamalPubkey', getAddressDecoder()),
    ('decryptableSupply', getDecryptableBalanceDecoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(
      SolanaErrorCode.codecsInvalidByteLength,
      {
        'codecDescription':
            'initializeConfidentialMintBurn instruction decoder',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (InitializeConfidentialMintBurnInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(
      getU8Encoder().encode(42),
    ).read(bytes, offset + 0);
    getConstantDecoder(
      getU8Encoder().encode(0),
    ).read(bytes, offset + 1);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      InitializeConfidentialMintBurnInstructionData(
        supplyElgamalPubkey: map['supplyElgamalPubkey']! as Address,
        decryptableSupply: map['decryptableSupply']! as DecryptableBalance,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<InitializeConfidentialMintBurnInstructionData>(
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
      VariableSizeDecoder<InitializeConfidentialMintBurnInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  InitializeConfidentialMintBurnInstructionData,
  InitializeConfidentialMintBurnInstructionData
>
getInitializeConfidentialMintBurnInstructionDataCodec() {
  return combineCodec(
    getInitializeConfidentialMintBurnInstructionDataEncoder(),
    getInitializeConfidentialMintBurnInstructionDataDecoder(),
  );
}

/// Creates a [InitializeConfidentialMintBurn] instruction.
Instruction getInitializeConfidentialMintBurnInstruction({
  required Address programAddress,
  required Address mint,
  required Address supplyElgamalPubkey,
  required DecryptableBalance decryptableSupply,
}) {
  final instructionData = InitializeConfidentialMintBurnInstructionData(
    supplyElgamalPubkey: supplyElgamalPubkey,
    decryptableSupply: decryptableSupply,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: mint, role: AccountRole.writable),
    ],
    data: getInitializeConfidentialMintBurnInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [InitializeConfidentialMintBurn] instruction from raw instruction data.
InitializeConfidentialMintBurnInstructionData
parseInitializeConfidentialMintBurnInstruction(Instruction instruction) {
  return getInitializeConfidentialMintBurnInstructionDataDecoder().decode(
    instruction.data!,
  );
}
