// ignore_for_file: avoid_print
/// Example 05: Encode and decode fixed-width numbers.
///
/// Demonstrates the little-endian integer codecs (u8, u16, u32, u64, i8, i16,
/// i32, i64) that are used throughout Solana instruction data and account
/// layouts.
///
/// Run:
///   dart examples/05_number_codecs.dart
library;

import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

void main() {
  // ── u8 (1 byte) ───────────────────────────────────────────────────────────
  final u8Codec = getU8Codec();
  final u8Encoded = u8Codec.encode(255);
  final u8Decoded = u8Codec.decode(u8Encoded);
  print('u8  255  → bytes: $u8Encoded → decoded: $u8Decoded');

  // ── u16 (2 bytes, little-endian) ──────────────────────────────────────────
  final u16Codec = getU16Codec();
  final u16Encoded = u16Codec.encode(1000);
  final u16Decoded = u16Codec.decode(u16Encoded);
  print('u16 1000 → bytes: $u16Encoded → decoded: $u16Decoded');

  // ── u32 (4 bytes, little-endian) ──────────────────────────────────────────
  final u32Codec = getU32Codec();
  final u32Encoded = u32Codec.encode(0xDEADBEEF);
  final u32Decoded = u32Codec.decode(u32Encoded);
  print('u32 0xDEADBEEF → bytes: $u32Encoded → decoded: 0x'
      '${u32Decoded.toRadixString(16).toUpperCase()}');

  // ── u64 (8 bytes, little-endian, BigInt) ──────────────────────────────────
  // u64 uses BigInt because Dart's int is 64-bit signed; u64 max exceeds it.
  final u64Codec = getU64Codec();
  final lamports = BigInt.from(1_000_000_000); // 1 SOL in lamports
  final u64Encoded = u64Codec.encode(lamports);
  final u64Decoded = u64Codec.decode(u64Encoded);
  print('u64 1_000_000_000 → bytes: $u64Encoded → decoded: $u64Decoded');

  // ── i8 (signed 1 byte) ────────────────────────────────────────────────────
  final i8Codec = getI8Codec();
  final i8Encoded = i8Codec.encode(-1);
  final i8Decoded = i8Codec.decode(i8Encoded);
  print('i8  -1   → bytes: $i8Encoded → decoded: $i8Decoded');

  // ── i64 (signed 8 bytes, BigInt) ─────────────────────────────────────────
  final i64Codec = getI64Codec();
  final negBig = BigInt.from(-9007199254740992); // -2^53
  final i64Encoded = i64Codec.encode(negBig);
  final i64Decoded = i64Codec.decode(i64Encoded);
  print('i64 $negBig → bytes len: ${i64Encoded.length} → decoded: $i64Decoded');

  // ── f64 (IEEE 754 double, 8 bytes) ────────────────────────────────────────
  final f64Codec = getF64Codec();
  final f64Encoded = f64Codec.encode(3.14159);
  final f64Decoded = f64Codec.decode(f64Encoded);
  print('f64 3.14159 → bytes len: ${f64Encoded.length} → decoded: $f64Decoded');

  // ── Shortcut: encode only / decode only ───────────────────────────────────
  final encoder = getU32Encoder();
  final decoder = getU32Decoder();
  final bytes = encoder.encode(12345);
  print('u32 encoder/decoder round-trip: ${decoder.decode(bytes)}');
}
