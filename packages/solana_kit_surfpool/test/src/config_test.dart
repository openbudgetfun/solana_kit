import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

void main() {
  group('SurfnetConfig', () {
    const account = Address('11111111111111111111111111111111');
    const feature = Address('BPFLoaderUpgradeab1e11111111111111111111111');

    test('exposes defaults and block production CLI values', () {
      final config = SurfnetConfig();

      expect(config.offline, isTrue);
      expect(config.remoteRpcUrl, isNull);
      expect(config.blockProductionMode, BlockProductionMode.transaction);
      expect(BlockProductionMode.manual.cliValue, 'manual');
      expect(BlockProductionMode.clock.cliValue, 'clock');
      expect(BlockProductionMode.transaction.cliValue, 'transaction');
      expect(config.slotTimeMs, 1);
      expect(config.airdropSol, 10_000_000_000);
      expect(config.airdropLamports, 10_000_000_000);
      expect(config.airdropAddresses, isEmpty);
      expect(config.payerSecretKey, isNull);
      expect(config.enableFeatures, isEmpty);
      expect(config.disableFeatures, isEmpty);
      expect(config.allFeatures, isFalse);
      expect(config.skipBlockhashCheck, isFalse);
      expect(config.host, '127.0.0.1');
      expect(config.rpcPort, isNull);
      expect(config.wsPort, isNull);
    });

    test('defensively copies lists and payer secret key', () {
      final airdrops = <Address>[account];
      final enables = <Address>[feature];
      final disables = <Address>[account];
      final payerSecretKey = Uint8List.fromList(List<int>.filled(64, 7));
      final config = SurfnetConfig(
        airdropAddresses: airdrops,
        payerSecretKey: payerSecretKey,
        enableFeatures: enables,
        disableFeatures: disables,
      );

      airdrops.clear();
      enables.clear();
      disables.clear();
      payerSecretKey[0] = 9;
      final exposedSecretKey = config.payerSecretKey;
      expect(exposedSecretKey, isNotNull);
      exposedSecretKey![1] = 9;

      expect(config.airdropAddresses, <Address>[account]);
      expect(config.enableFeatures, <Address>[feature]);
      expect(config.disableFeatures, <Address>[account]);
      expect(config.payerSecretKey!.take(2), <int>[7, 7]);
      expect(
        () => config.airdropAddresses.add(feature),
        throwsUnsupportedError,
      );
      expect(() => config.enableFeatures.add(account), throwsUnsupportedError);
      expect(() => config.disableFeatures.add(feature), throwsUnsupportedError);
    });

    test('rejects invalid timing, funding, and ports', () {
      expect(
        () => SurfnetConfig(slotTimeMs: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SurfnetConfig(airdropSol: -1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SurfnetConfig(rpcPort: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SurfnetConfig(wsPort: 65_536),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SurfnetConfig(rpcPort: 8899, wsPort: 8899),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
