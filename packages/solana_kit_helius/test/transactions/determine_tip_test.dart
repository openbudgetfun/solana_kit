import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('determineTipSol', () {
    test('uses fetched tip floor when higher than Sender minimum', () async {
      final tip = await determineTipSol(
        swqosOnly: false,
        fetchTipFloor: () async => 0.002,
      );

      expect(tip, BigInt.from(2000000));
    });

    test('floors to 0.0005 SOL for SWQoS routes', () async {
      double? converted;
      final tip = await determineTipSol(
        swqosOnly: true,
        fetchTipFloor: () async => 0.0001,
        toLamports: (sol) {
          converted = sol;
          return BigInt.from(500000);
        },
      );

      expect(tip, BigInt.from(500000));
      expect(converted, swqosMinimumTipSol);
    });

    test('falls back to dual-route minimum when fetch fails', () async {
      double? converted;
      final tip = await determineTipSol(
        swqosOnly: false,
        fetchTipFloor: () async => null,
        toLamports: (sol) {
          converted = sol;
          return BigInt.from(1000000);
        },
      );

      expect(tip, BigInt.from(1000000));
      expect(converted, dualRouteMinimumTipSol);
    });
  });
}
