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
class CreateTokenizedAttestationInstructionData {
  const CreateTokenizedAttestationInstructionData({
    required this.nonce,
    required this.data,
    required this.expiry,
    required this.name,
    required this.uri,
    required this.symbol,
    required this.mintAccountSpace,
  }) : discriminator = 10;

  final int discriminator;
  final Address nonce;
  final Uint8List data;
  final BigInt expiry;
  final String name;
  final String uri;
  final String symbol;
  final int mintAccountSpace;
}

Encoder<CreateTokenizedAttestationInstructionData>
getCreateTokenizedAttestationInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getU8Encoder()),
    ('nonce', getAddressEncoder()),
    ('data', addEncoderSizePrefix(getBytesEncoder(), getU32Encoder())),
    ('expiry', getI64Encoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('symbol', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('mintAccountSpace', getU16Encoder()),
  ]);

  return transformEncoder(
    structEncoder,
    (CreateTokenizedAttestationInstructionData value) => <String, Object?>{
      'discriminator': 10,
      'nonce': value.nonce,
      'data': value.data,
      'expiry': value.expiry,
      'name': value.name,
      'uri': value.uri,
      'symbol': value.symbol,
      'mintAccountSpace': value.mintAccountSpace,
    },
  );
}

Decoder<CreateTokenizedAttestationInstructionData>
getCreateTokenizedAttestationInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getU8Decoder()),
    ('nonce', getAddressDecoder()),
    ('data', addDecoderSizePrefix(getBytesDecoder(), getU32Decoder())),
    ('expiry', getI64Decoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('symbol', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('mintAccountSpace', getU16Decoder()),
  ]);

  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw SolanaError(SolanaErrorCode.codecsInvalidByteLength, {
      'codecDescription': 'createTokenizedAttestation instruction decoder',
      'expected': expected,
      'bytesLength': bytesLength,
    });
  }

  (CreateTokenizedAttestationInstructionData, int) readTopLevel(
    Uint8List bytes,
    int offset,
  ) {
    getConstantDecoder(getU8Encoder().encode(10)).read(bytes, offset + 0);
    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }

    return (
      CreateTokenizedAttestationInstructionData(
        nonce: map['nonce']! as Address,
        data: map['data']! as Uint8List,
        expiry: map['expiry']! as BigInt,
        name: map['name']! as String,
        uri: map['uri']! as String,
        symbol: map['symbol']! as String,
        mintAccountSpace: map['mintAccountSpace']! as int,
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    FixedSizeDecoder<Map<String, Object?>>() =>
      FixedSizeDecoder<CreateTokenizedAttestationInstructionData>(
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
      VariableSizeDecoder<CreateTokenizedAttestationInstructionData>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };
}

Codec<
  CreateTokenizedAttestationInstructionData,
  CreateTokenizedAttestationInstructionData
>
getCreateTokenizedAttestationInstructionDataCodec() {
  return combineCodec(
    getCreateTokenizedAttestationInstructionDataEncoder(),
    getCreateTokenizedAttestationInstructionDataDecoder(),
  );
}

/// Creates a [CreateTokenizedAttestation] instruction.
Instruction getCreateTokenizedAttestationInstruction({
  required Address programAddress,
  required Address payer,
  required Address authority,
  required Address credential,
  required Address schema,
  required Address attestation,
  required Address systemProgram,
  required Address schemaMint,
  required Address attestationMint,
  required Address sasPda,
  required Address recipientTokenAccount,
  required Address recipient,
  required Address tokenProgram,
  required Address associatedTokenProgram,
  required Address nonce,
  required Uint8List data,
  required BigInt expiry,
  required String name,
  required String uri,
  required String symbol,
  required int mintAccountSpace,
}) {
  final instructionData = CreateTokenizedAttestationInstructionData(
    nonce: nonce,
    data: data,
    expiry: expiry,
    name: name,
    uri: uri,
    symbol: symbol,
    mintAccountSpace: mintAccountSpace,
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
      AccountMeta(address: schemaMint, role: AccountRole.writable),
      AccountMeta(address: attestationMint, role: AccountRole.writable),
      AccountMeta(address: sasPda, role: AccountRole.readonly),
      AccountMeta(address: recipientTokenAccount, role: AccountRole.writable),
      AccountMeta(address: recipient, role: AccountRole.readonly),
      AccountMeta(address: tokenProgram, role: AccountRole.readonly),
      AccountMeta(address: associatedTokenProgram, role: AccountRole.readonly),
    ],
    data: getCreateTokenizedAttestationInstructionDataEncoder().encode(
      instructionData,
    ),
  );
}

/// Parses a [CreateTokenizedAttestation] instruction from raw instruction data.
CreateTokenizedAttestationInstructionData
parseCreateTokenizedAttestationInstruction(Instruction instruction) {
  return getCreateTokenizedAttestationInstructionDataDecoder().decode(
    instruction.data!,
  );
}
