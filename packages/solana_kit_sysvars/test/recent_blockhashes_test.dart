import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('recent blockhashes', () {
    test('decode', () {
      // From TS test: recent-blockhashes-test.ts
      final recentBlockhashesState = Uint8List.fromList([
        // array length (u32)
        2, 0, 0, 0,
        // entry 1: blockhash (32 bytes of 0x01)
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        // entry 1: lamportsPerSignature
        134, 74, 2, 0, 0, 0, 0, 0,
        // entry 2: blockhash (32 bytes of 0x02)
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
        // entry 2: lamportsPerSignature
        134, 74, 2, 0, 0, 0, 0, 0,
      ]);

      final result = getSysvarRecentBlockhashesCodec().decode(
        recentBlockhashesState,
      );
      expect(result, hasLength(2));
      expect(
        result[0].blockhash.value,
        equals('4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi'),
      );
      expect(
        result[0].feeCalculator.lamportsPerSignature,
        equals(Lamports(BigInt.from(150150))),
      );
      expect(
        result[1].blockhash.value,
        equals('8qbHbw2BbbTHBW1sbeqakYXVKRQM8Ne7pLK7m6CVfeR'),
      );
      expect(
        result[1].feeCalculator.lamportsPerSignature,
        equals(Lamports(BigInt.from(150150))),
      );
    });

    test('encode roundtrip', () {
      final entries = [
        RecentBlockhashEntry(
          blockhash: const Blockhash(
            '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
          ),
          feeCalculator: FeeCalculator(
            lamportsPerSignature: Lamports(BigInt.from(150150)),
          ),
        ),
        RecentBlockhashEntry(
          blockhash: const Blockhash(
            '8qbHbw2BbbTHBW1sbeqakYXVKRQM8Ne7pLK7m6CVfeR',
          ),
          feeCalculator: FeeCalculator(
            lamportsPerSignature: Lamports(BigInt.from(150150)),
          ),
        ),
      ];

      final codec = getSysvarRecentBlockhashesCodec();
      final encoded = codec.encode(entries);
      final decoded = codec.decode(encoded);

      expect(decoded, hasLength(2));
      expect(decoded[0].blockhash.value, equals(entries[0].blockhash.value));
      expect(
        decoded[0].feeCalculator.lamportsPerSignature,
        equals(entries[0].feeCalculator.lamportsPerSignature),
      );
      expect(decoded[1].blockhash.value, equals(entries[1].blockhash.value));
      expect(
        decoded[1].feeCalculator.lamportsPerSignature,
        equals(entries[1].feeCalculator.lamportsPerSignature),
      );
    });

    test('codec is variable-size', () {
      final codec = getSysvarRecentBlockhashesCodec();
      expect(isFixedSize(codec), isFalse);
    });

    test('RecentBlockhashEntry equality', () {
      final a = RecentBlockhashEntry(
        blockhash: const Blockhash(
          '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
        ),
        feeCalculator: FeeCalculator(
          lamportsPerSignature: Lamports(BigInt.from(100)),
        ),
      );
      final b = RecentBlockhashEntry(
        blockhash: const Blockhash(
          '4vJ9JU1bJJE96FWSJKvHsmmFADCg4gpZQff4P3bkLKi',
        ),
        feeCalculator: FeeCalculator(
          lamportsPerSignature: Lamports(BigInt.from(100)),
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
