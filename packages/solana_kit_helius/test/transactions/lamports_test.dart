import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('solToLamports', () {
    test('converts whole SOL correctly', () {
      expect(solToLamports(1), BigInt.from(lamportsPerSol));
    });

    test('rounds to nearest lamport', () {
      expect(solToLamports(0.0000000014), BigInt.one);
      expect(solToLamports(0.0000000005), BigInt.one);
    });

    test('handles fractional SOL', () {
      const value = 1.23456789;
      expect(
        solToLamports(value),
        BigInt.from((value * lamportsPerSol).round()),
      );
    });
  });
}
