import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('stake history', () {
    test('decode', () {
      // From TS test: stake-history-test.ts
      final stakeHistoryState = Uint8List.fromList([
        // array length (u64)
        2, 0, 0, 0, 0, 0, 0, 0,
        // entry 1: epoch
        1, 0, 0, 0, 0, 0, 0, 0,
        // entry 1: effective
        0, 208, 237, 144, 46, 0, 0, 0,
        // entry 1: activating
        0, 160, 219, 33, 93, 0, 0, 0,
        // entry 1: deactivating
        0, 112, 201, 178, 139, 0, 0, 0,
        // entry 2: epoch
        2, 0, 0, 0, 0, 0, 0, 0,
        // entry 2: effective
        0, 160, 219, 33, 93, 0, 0, 0,
        // entry 2: activating
        0, 112, 201, 178, 139, 0, 0, 0,
        // entry 2: deactivating
        0, 64, 183, 67, 186, 0, 0, 0,
      ]);

      final result = getSysvarStakeHistoryCodec().decode(stakeHistoryState);
      expect(result, hasLength(2));

      expect(result[0].epoch, equals(BigInt.from(1)));
      expect(
        result[0].stakeHistory.effective,
        equals(Lamports(BigInt.from(200000000000))),
      );
      expect(
        result[0].stakeHistory.activating,
        equals(Lamports(BigInt.from(400000000000))),
      );
      expect(
        result[0].stakeHistory.deactivating,
        equals(Lamports(BigInt.from(600000000000))),
      );

      expect(result[1].epoch, equals(BigInt.from(2)));
      expect(
        result[1].stakeHistory.effective,
        equals(Lamports(BigInt.from(400000000000))),
      );
      expect(
        result[1].stakeHistory.activating,
        equals(Lamports(BigInt.from(600000000000))),
      );
      expect(
        result[1].stakeHistory.deactivating,
        equals(Lamports(BigInt.from(800000000000))),
      );
    });

    test('encode roundtrip', () {
      final entries = [
        StakeHistoryEntry(
          epoch: BigInt.from(1),
          stakeHistory: StakeHistoryData(
            effective: Lamports(BigInt.from(200000000000)),
            activating: Lamports(BigInt.from(400000000000)),
            deactivating: Lamports(BigInt.from(600000000000)),
          ),
        ),
        StakeHistoryEntry(
          epoch: BigInt.from(2),
          stakeHistory: StakeHistoryData(
            effective: Lamports(BigInt.from(400000000000)),
            activating: Lamports(BigInt.from(600000000000)),
            deactivating: Lamports(BigInt.from(800000000000)),
          ),
        ),
      ];

      final codec = getSysvarStakeHistoryCodec();
      final encoded = codec.encode(entries);
      final decoded = codec.decode(encoded);

      expect(decoded, hasLength(2));
      expect(decoded[0].epoch, equals(entries[0].epoch));
      expect(
        decoded[0].stakeHistory.effective,
        equals(entries[0].stakeHistory.effective),
      );
      expect(
        decoded[0].stakeHistory.activating,
        equals(entries[0].stakeHistory.activating),
      );
      expect(
        decoded[0].stakeHistory.deactivating,
        equals(entries[0].stakeHistory.deactivating),
      );
      expect(decoded[1].epoch, equals(entries[1].epoch));
      expect(
        decoded[1].stakeHistory.effective,
        equals(entries[1].stakeHistory.effective),
      );
    });

    test('codec is variable-size', () {
      final codec = getSysvarStakeHistoryCodec();
      expect(isFixedSize(codec), isFalse);
    });

    test('StakeHistoryEntry equality', () {
      final a = StakeHistoryEntry(
        epoch: BigInt.from(1),
        stakeHistory: StakeHistoryData(
          effective: Lamports(BigInt.from(100)),
          activating: Lamports(BigInt.from(200)),
          deactivating: Lamports(BigInt.from(300)),
        ),
      );
      final b = StakeHistoryEntry(
        epoch: BigInt.from(1),
        stakeHistory: StakeHistoryData(
          effective: Lamports(BigInt.from(100)),
          activating: Lamports(BigInt.from(200)),
          deactivating: Lamports(BigInt.from(300)),
        ),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('StakeHistoryData equality', () {
      final a = StakeHistoryData(
        effective: Lamports(BigInt.from(100)),
        activating: Lamports(BigInt.from(200)),
        deactivating: Lamports(BigInt.from(300)),
      );
      final b = StakeHistoryData(
        effective: Lamports(BigInt.from(100)),
        activating: Lamports(BigInt.from(200)),
        deactivating: Lamports(BigInt.from(300)),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
