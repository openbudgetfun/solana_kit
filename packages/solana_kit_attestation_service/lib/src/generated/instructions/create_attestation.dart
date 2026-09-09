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
class CreateAttestationInstructionData {
  const CreateAttestationInstructionData({
    required this.nonce,
    required this.data,
    required this.expiry,
  }) : discriminator = 6;

  final int discriminator;
  final Address nonce;
  final Uint8List data;
  final BigInt expiry;
}

Encoder<CreateAttestationInstructionData>
getCreateAttestationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('nonce', getAddressEncoder()),
    ('data', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    ('expiry', getI64Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateAttestationInstructionData value) => <String, Object?>{
      'discriminator': 6,
      'nonce': value.nonce,
      'data': value.data,
      'expiry': value.expiry,
    },
  );
}

Decoder<CreateAttestationInstructionData>
getCreateAttestationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('nonce', getAddressDecoder()),
    ('data', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('expiry', getI64Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'createAttestation instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (CreateAttestationInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(6)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateAttestationInstructionData(
        nonce: map['nonce']! as Address,
        data: map['data']! as Uint8List,
        expiry: map['expiry']! as BigInt,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateAttestationInstructionData>(
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
      VariableSizeDecoder<CreateAttestationInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<CreateAttestationInstructionData, CreateAttestationInstructionData>
getCreateAttestationInstructionDataCodec() {
  return combineCodec(
    getCreateAttestationInstructionDataEncoder(),
    getCreateAttestationInstructionDataDecoder(),
  );
}

/// Creates a [CreateAttestation] instruction.
Instruction getCreateAttestationInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address schema,
  required Address attestation,
  required Address systemProgram,
  required Address nonce,
  required Uint8List data,
  required BigInt expiry,
}) {
  final instructionData = CreateAttestationInstructionData(
    nonce: nonce,
    data: data,
    expiry: expiry,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
      AccountMeta(address: payer, role: AccountRole.writableSigner),
      AccountMeta(address: authority, role: AccountRole.readonlySigner),
      AccountMeta(address: credential, role: AccountRole.readonly),
      AccountMeta(address: schema, role: AccountRole.readonly),
      AccountMeta(address: attestation, role: AccountRole.writable),
      AccountMeta(address: systemProgram, role: AccountRole.readonly),
    ],
    data: getCreateAttestationInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [CreateAttestation] instruction from raw instruction data.
CreateAttestationInstructionData parseCreateAttestationInstruction(
  Instruction instruction,
) {
  return getCreateAttestationInstructionDataDecoder().decode(instruction.data!);
}
