// ignore_for_file: avoid_print
/// Example 07: Encode and decode a struct (account layout).
///
/// Demonstrates [getStructCodec] to model a simple on-chain account layout
/// with mixed field types – a common pattern when reading Solana program data.
///
/// Run:
///   dart examples/07_struct_codec.dart
library;

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';
import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';

void main() {
  // Each field is a (name, codec) pair.
  // fixEncoderSize / fixDecoderSize lock a variable-size base58 codec to 32 b.
  final mintCodec = combineCodec(
    fixEncoderSize(getBase58Encoder(), 32),
    fixDecoderSize(getBase58Decoder(), 32),
  );

  // Build a struct codec that round-trips Map<String, Object?> values.
  // Field order determines byte layout.
  // getStructCodec takes no type parameters – it always works with
  // Map<String, Object?>.
  final tokenAccountCodec = getStructCodec([
    ('mint', mintCodec),                 // 32 bytes
    ('owner', mintCodec),                // 32 bytes
    ('amount', getU64Codec()),           // 8 bytes (BigInt)
    ('isInitialized', getBooleanCodec()), // 1 byte
  ]);

  // ── 1. Encode ─────────────────────────────────────────────────────────────
  final account = <String, Object?>{
    'mint': 'So11111111111111111111111111111111111111112',
    'owner': '9B5XszUGdMaxCZ7uSQhPzdks5ZQSmWxrmzCSvtJ6Ns6g',
    'amount': BigInt.from(1_000_000),
    'isInitialized': true,
  };

  final encoded = tokenAccountCodec.encode(account);
  // 32 (mint) + 32 (owner) + 8 (u64) + 1 (bool) = 73 bytes
  print('Encoded length: ${encoded.length} bytes (expected 73)');

  // ── 2. Decode ─────────────────────────────────────────────────────────────
  final decoded = tokenAccountCodec.decode(encoded);
  print('Decoded mint  : ${decoded['mint']}');
  print('Decoded owner : ${decoded['owner']}');
  print('Decoded amount: ${decoded['amount']}');
  print('Is initialized: ${decoded['isInitialized']}');

  // ── 3. Round-trip check ───────────────────────────────────────────────────
  final mintOk = decoded['mint'] == account['mint'];
  final amountOk = decoded['amount'] == account['amount'];
  print('Round-trip OK: ${mintOk && amountOk}');

  // ── 4. Array of u8 ────────────────────────────────────────────────────────
  // Use getArrayCodec when you need a variable-length sequence of homogeneous
  // values (e.g. a list of instructions or seed bytes).
  final u8ArrayCodec = getArrayCodec(getU8Codec());
  final arrEncoded = u8ArrayCodec.encode([1, 2, 3, 4, 5]);
  final arrDecoded = u8ArrayCodec.decode(arrEncoded);
  print('\nu8 array round-trip: $arrDecoded');
}
