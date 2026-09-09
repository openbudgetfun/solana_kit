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
class TokenizeSchemaInstructionData {
  const TokenizeSchemaInstructionData({required this.maxSize})
    : discriminator = 9;

  final int discriminator;
  final BigInt maxSize;
}

Encoder<TokenizeSchemaInstructionData>
getTokenizeSchemaInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('maxSize', getU64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (TokenizeSchemaInstructionData value) => <String, Object?>{
      'discriminator': 9,
      'maxSize': value.maxSize,
    },
  );
}

Decoder<TokenizeSchemaInstructionData>
getTokenizeSchemaInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('maxSize', getU64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'tokenizeSchema instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (TokenizeSchemaInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(9)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      TokenizeSchemaInstructionData(maxSize: map['maxSize']! as BigInt),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<TokenizeSchemaInstructionData>(
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
      VariableSizeDecoder<TokenizeSchemaInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<TokenizeSchemaInstructionData, TokenizeSchemaInstructionData>
getTokenizeSchemaInstructionDataCodec() {
  return combineCodec(
    getTokenizeSchemaInstructionDataEncoder(),
    getTokenizeSchemaInstructionDataDecoder(),
  );
}

/// Creates a [TokenizeSchema] instruction.
Instruction getTokenizeSchemaInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address schema,
  required Address mint,
  required Address sasPda,
  required Address systemProgram,
  required Address tokenProgram,
  required BigInt maxSize,
}) {
  final instructionData = TokenizeSchemaInstructionData(maxSize: maxSize);

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: credential, role: AccountRole.readonly),
      AccountMeta(address: schema, role: AccountRole.readonly),
      AccountMeta(address: mint, role: AccountRole.writable),
      AccountMeta(address: sasPda, role: AccountRole.readonly),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
    ],
    data: getTokenizeSchemaInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [TokenizeSchema] instruction from raw instruction data.
TokenizeSchemaInstructionData parseTokenizeSchemaInstruction(
  Instruction instruction,
) {
  return getTokenizeSchemaInstructionDataDecoder().decode(instruction.data!);
}
