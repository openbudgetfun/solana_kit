// ignore_for_file: avoid_print
/// Example 25: Discriminated union codec and Union2 types.
///
/// Solana programs often use a 1-byte discriminator at the start of account
/// data to identify its type.  This example shows the typed
/// [Union2Variant0] / [Union2Variant1] approach and the map-based
/// [getDiscriminatedUnionEncoder] that mirrors the TS SDK / Anchor pattern.
///
/// Run:
///   dart examples/25_union_codec.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  // ────────────────────────────────────────────────────────────────────────────
  // Part A: Typed Union2 with explicit variant wrappers
  // ────────────────────────────────────────────────────────────────────────────

  // Build a union of two fixed-size variants: u32 (variant 0) or u8 (variant 1).
  // The `getIndexFromBytes` callback reads the first byte to pick the variant.
  final union2Codec = getUnion2Codec(
    getU32Codec(),
    getU8Codec(),
    (Uint8List bytes, int offset) => bytes[offset] < 4 ? 0 : 1,
  );

  // Encode variant 0 (u32 value 42).
  final encodedV0 = union2Codec.encode(Union2Variant0(42));
  print('Union2 variant 0 encoded: $encodedV0 (${encodedV0.length} bytes)');

  // Encode variant 1 (u8 value 200).
  final encodedV1 = union2Codec.encode(Union2Variant1(200));
  print('Union2 variant 1 encoded: $encodedV1 (${encodedV1.length} bytes)');

  // Decode variant 0.
  final decoded0 = union2Codec.decode(encodedV0);
  switch (decoded0) {
    case Union2Variant0(:final value):
      print('Decoded variant 0 value: $value (type: ${value.runtimeType})');
    case Union2Variant1(:final value):
      print('Decoded as variant 1: $value');
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Part B: Map-based discriminated union (mirrors Anchor account discriminators)
  // ────────────────────────────────────────────────────────────────────────────

  // Build the per-variant struct codecs first.
  // getStructCodec takes no type parameters.
  final vaultVariantCodec = getStructCodec([('balance', getU64Codec())]);
  final metaVariantCodec = getStructCodec([('nameLen', getU32Codec())]);

  // Each entry is (discriminatorValue, encoder/decoder).
  final discriminatedEncoder = getDiscriminatedUnionEncoder([
    ('TokenVault', encoderFromCodec(vaultVariantCodec)),
    ('Metadata', encoderFromCodec(metaVariantCodec)),
  ]);

  final discriminatedDecoder = getDiscriminatedUnionDecoder([
    ('TokenVault', decoderFromCodec(vaultVariantCodec)),
    ('Metadata', decoderFromCodec(metaVariantCodec)),
  ]);

  // Encode a TokenVault (discriminator index = 0).
  final vaultMap = <String, Object?>{
    '__kind': 'TokenVault',
    'balance': BigInt.from(1_000_000_000),
  };
  final vaultEncoded = discriminatedEncoder.encode(vaultMap);
  print('\nDiscriminated vault encoded: $vaultEncoded '
      '(${vaultEncoded.length} bytes)');
  print('First byte (discriminator): 0x'
      '${vaultEncoded[0].toRadixString(16).padLeft(2, '0')}');

  final vaultDecoded = discriminatedDecoder.decode(vaultEncoded);
  print('Decoded __kind  : ${vaultDecoded['__kind']}');
  print('Decoded balance : ${vaultDecoded['balance']}');
}
