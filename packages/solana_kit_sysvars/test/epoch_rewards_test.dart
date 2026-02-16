import 'dart:typed_data';

import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:solana_kit_sysvars/solana_kit_sysvars.dart';
import 'package:test/test.dart';

void main() {
  group('epoch rewards', () {
    test('decode', () {
      // From TS test: epoch-rewards-test.ts
      final epochRewardsState = Uint8List.fromList([
        // distributionStartingBlockHeight
        0xab, 0xa8, 0x87, 0x12, 0x00, 0x00, 0x00, 0x00,
        // numPartitions
        0x3a, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        // parentBlockhash
        0x67, 0x8b, 0xd4, 0xe4, 0xc8, 0x5c, 0x10, 0x87,
        0xa8, 0x0a, 0xfb, 0x2f, 0x0d, 0xbb, 0x13, 0x27,
        0x16, 0x11, 0x3a, 0xc7, 0xc7, 0xb0, 0xc7, 0xe4,
        0x99, 0x51, 0x4d, 0x42, 0xdb, 0x43, 0xd7, 0x1c,
        // totalPoints
        0x10, 0xbe, 0x90, 0x99, 0x7a, 0x16, 0x9e, 0xa5,
        0xc2, 0x2d, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
        // totalRewards
        0x00, 0xb3, 0x04, 0x4e, 0xd0, 0x20, 0x89, 0x00,
        // distributedRewards
        0x00, 0xb8, 0xea, 0x37, 0xd0, 0x20, 0x89, 0x00,
        // active
        0x00,
      ]);

      final result = getSysvarEpochRewardsCodec().decode(epochRewardsState);
      expect(
        result.distributionStartingBlockHeight,
        equals(BigInt.from(310880427)),
      );
      expect(result.numPartitions, equals(BigInt.from(314)));
      expect(
        result.parentBlockhash.value,
        equals('7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj'),
      );
      expect(
        result.totalPoints,
        equals(BigInt.parse('2633948733309470433656336')),
      );
      expect(
        result.totalRewards,
        equals(Lamports(BigInt.parse('38598150843577088'))),
      );
      expect(
        result.distributedRewards,
        equals(Lamports(BigInt.parse('38598150472775680'))),
      );
      expect(result.active, isFalse);
    });

    test('encode roundtrip', () {
      final rewards = SysvarEpochRewards(
        distributionStartingBlockHeight: BigInt.from(310880427),
        numPartitions: BigInt.from(314),
        parentBlockhash: const Blockhash(
          '7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj',
        ),
        totalPoints: BigInt.parse('2633948733309470433656336'),
        totalRewards: Lamports(BigInt.parse('38598150843577088')),
        distributedRewards: Lamports(BigInt.parse('38598150472775680')),
        active: false,
      );

      final codec = getSysvarEpochRewardsCodec();
      final encoded = codec.encode(rewards);
      final decoded = codec.decode(encoded);

      expect(
        decoded.distributionStartingBlockHeight,
        equals(rewards.distributionStartingBlockHeight),
      );
      expect(decoded.numPartitions, equals(rewards.numPartitions));
      expect(
        decoded.parentBlockhash.value,
        equals(rewards.parentBlockhash.value),
      );
      expect(decoded.totalPoints, equals(rewards.totalPoints));
      expect(decoded.totalRewards, equals(rewards.totalRewards));
      expect(decoded.distributedRewards, equals(rewards.distributedRewards));
      expect(decoded.active, equals(rewards.active));
    });

    test('encoder has correct fixed size', () {
      final encoder = getSysvarEpochRewardsEncoder();
      expect(encoder.fixedSize, equals(sysvarEpochRewardsSize));
      expect(encoder.fixedSize, equals(81));
      expect(isFixedSize(encoder), isTrue);
    });

    test('SysvarEpochRewards equality', () {
      final a = SysvarEpochRewards(
        distributionStartingBlockHeight: BigInt.from(100),
        numPartitions: BigInt.from(10),
        parentBlockhash: const Blockhash(
          '7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj',
        ),
        totalPoints: BigInt.from(1000),
        totalRewards: Lamports(BigInt.from(500)),
        distributedRewards: Lamports(BigInt.from(200)),
        active: true,
      );
      final b = SysvarEpochRewards(
        distributionStartingBlockHeight: BigInt.from(100),
        numPartitions: BigInt.from(10),
        parentBlockhash: const Blockhash(
          '7yCfKTaamnrmkAfefSgsonQ6rtwCfVaxQJircWb9K4Qj',
        ),
        totalPoints: BigInt.from(1000),
        totalRewards: Lamports(BigInt.from(500)),
        distributedRewards: Lamports(BigInt.from(200)),
        active: true,
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
