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
class CreateCredentialInstructionData {
  const CreateCredentialInstructionData({
    required this.name,
    required this.signers,
  }) : discriminator = 0;

  final int discriminator;
  final String name;
  final List<Address> signers;
}

Encoder<CreateCredentialInstructionData>
getCreateCredentialInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    (
      'signers',
      getArrayEncoder(
        transformEncoder(getAddressEncoder(), (Address value) => value),
      ),
    ),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateCredentialInstructionData value) => <String, Object?>{
      'discriminator': 0,
      'name': value.name,
      'signers': value.signers,
    },
  );
}

Decoder<CreateCredentialInstructionData>
getCreateCredentialInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('signers', getArrayDecoder(getAddressDecoder())),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'createCredential instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (CreateCredentialInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(0)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateCredentialInstructionData(
        name: map['name']! as String,
        signers: map['signers']! as List<Address>,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateCredentialInstructionData>(
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
      VariableSizeDecoder<CreateCredentialInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateCredentialInstructionData, CreateCredentialInstructionData>
getCreateCredentialInstructionDataCodec() {
  return combineCodec(
    getCreateCredentialInstructionDataEncoder(),
    getCreateCredentialInstructionDataDecoder(),
  );
}

/// Creates a [CreateCredential] instruction.
Instruction getCreateCredentialInstruction({
  required Address programAddress,
  required Address payer,
  required Address credential,
  required Address authority,
  required Address systemProgram,
  required String name,
  required List<Address> signers,
}) {
  final instructionData = CreateCredentialInstructionData(
    name: name,
    signers: signers,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: credential, role: AccountRole.writable),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateCredentialInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateCredential] instruction from raw instruction data.
CreateCredentialInstructionData parseCreateCredentialInstruction(
  Instruction instruction,
) {
  return getCreateCredentialInstructionDataDecoder().decode(instruction.data!);
}
