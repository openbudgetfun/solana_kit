// Auto-generated. Do not edit.
// ignore_for_file: type=lint


import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// The discriminator field name: 'discriminator'.
/// Offset: 0.

@immutable
class InitializeTokenMetadataInstructionData {
  InitializeTokenMetadataInstructionData({
    Uint8List? discriminator,
    required this.name,
    required this.symbol,
    required this.uri,
  }) :
      discriminator = discriminator ?? Uint8List.fromList([210, 225, 30, 162, 88, 184, 77, 141]);

  final Uint8List discriminator;
  final String name;
  final String symbol;
  final String uri;
}

Encoder<InitializeTokenMetadataInstructionData> getInitializeTokenMetadataInstructionDataEncoder() {
  final structEncoder = getStructEncoder(<(String, Encoder<Object?>)>[
    ('discriminator', getBytesEncoder()),
    ('name', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('symbol', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
    ('uri', addEncoderSizePrefix(getUtf8Encoder(), getU32Encoder())),
  ]);

  return transformEncoder(
    structEncoder,
    (InitializeTokenMetadataInstructionData value) => <String, Object?>{
      'discriminator': value.discriminator,
      'name': value.name,
      'symbol': value.symbol,
      'uri': value.uri,
    },
  );
}

Decoder<InitializeTokenMetadataInstructionData> getInitializeTokenMetadataInstructionDataDecoder() {
  final structDecoder = getStructDecoder(<(String, Decoder<Object?>)>[
    ('discriminator', getBytesDecoder()),
    ('name', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('symbol', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
    ('uri', addDecoderSizePrefix(getUtf8Decoder(), getU32Decoder())),
  ]);

  return transformDecoder(
    structDecoder,
    (Map<String, Object?> map, Uint8List bytes, int offset) => InitializeTokenMetadataInstructionData(
      discriminator: map['discriminator']! as Uint8List,
      name: map['name']! as String,
      symbol: map['symbol']! as String,
      uri: map['uri']! as String,
    ),
  );
}

Codec<InitializeTokenMetadataInstructionData, InitializeTokenMetadataInstructionData> getInitializeTokenMetadataInstructionDataCodec() {
  return combineCodec(getInitializeTokenMetadataInstructionDataEncoder(), getInitializeTokenMetadataInstructionDataDecoder());
}

/// Creates a [InitializeTokenMetadata] instruction.
Instruction getInitializeTokenMetadataInstruction({
  required Address programAddress,
  required Address metadata,
  required Address updateAuthority,
  required Address mint,
  required Address mintAuthority,
  required String name,
  required String symbol,
  required String uri,
}) {
  final instructionData = InitializeTokenMetadataInstructionData(
      name: name,
      symbol: symbol,
      uri: uri,
  );

  return Instruction(
    programAddress: programAddress,
    accounts: [
    AccountMeta(address: metadata, role: AccountRole.writable),
    AccountMeta(address: updateAuthority, role: AccountRole.readonly),
    AccountMeta(address: mint, role: AccountRole.readonly),
    AccountMeta(address: mintAuthority, role: AccountRole.readonlySigner),
    ],
    data: getInitializeTokenMetadataInstructionDataEncoder().encode(instructionData),
  );
}

/// Parses a [InitializeTokenMetadata] instruction from raw instruction data.
InitializeTokenMetadataInstructionData parseInitializeTokenMetadataInstruction(Instruction instruction) {
  return getInitializeTokenMetadataInstructionDataDecoder().decode(instruction.data!);
}
