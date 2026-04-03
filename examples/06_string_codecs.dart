// ignore_for_file: avoid_print
/// Example 06: Base58, Base64, Base16, and UTF-8 string codecs.
///
/// Shows how to use the string codec family for Solana-facing conversions
/// (addresses, transaction signatures, account data, etc.).
///
/// Run:
///   dart examples/06_string_codecs.dart
library;

import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  // ── Base58 ─────────────────────────────────────────────────────────────────
  // Base58 is used for Solana addresses and transaction signatures.
  final base58Codec = getBase58Codec();

  // Encode a base58 string into bytes.
  const systemProgram = '11111111111111111111111111111111';
  final addrBytes = base58Codec.encode(systemProgram);
  print('base58 → bytes (${addrBytes.length}): '
      '${addrBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join('')}');

  // Decode bytes back to a base58 string.
  final addrStr = base58Codec.decode(addrBytes);
  print('bytes → base58: $addrStr');
  print('Round-trip matches: ${addrStr == systemProgram}');

  // ── Base64 ─────────────────────────────────────────────────────────────────
  // Base64 is used for account data in JSON-RPC responses.
  final base64Codec = getBase64Codec();
  final someBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
  final base64Str = base64Codec.decode(someBytes);
  final base64Bytes = base64Codec.encode(base64Str);
  print('\nbase64 encode: $base64Str');
  print('base64 decode round-trip: $base64Bytes');

  // ── Base16 / hex ───────────────────────────────────────────────────────────
  final base16Codec = getBase16Codec();
  final hexStr = base16Codec.decode(someBytes);
  final hexBack = base16Codec.encode(hexStr);
  print('\nhex string: $hexStr');
  print('hex round-trip: $hexBack');

  // ── UTF-8 ──────────────────────────────────────────────────────────────────
  // getUtf8Codec is useful for memo instructions and offchain message content.
  final utf8Codec = getUtf8Codec();
  const greeting = 'Hello, Solana!';
  final utf8Bytes = utf8Codec.encode(greeting);
  final utf8Str = utf8Codec.decode(utf8Bytes);
  print('\nutf8 "$greeting" → ${utf8Bytes.length} bytes → "$utf8Str"');

  // ── Fixed-size Base58 (address-sized, 32 bytes) ───────────────────────────
  // Use fixEncoderSize when you need a fixed 32-byte output from base58.
  final fixedBase58Encoder = fixEncoderSize(getBase58Encoder(), 32);
  final fixed = fixedBase58Encoder.encode(systemProgram);
  print('\nFixed 32-byte base58 encoding length: ${fixed.length}');
}
