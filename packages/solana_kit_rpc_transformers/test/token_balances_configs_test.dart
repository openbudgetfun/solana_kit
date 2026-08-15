import 'package:solana_kit_rpc_transformers/solana_kit_rpc_transformers.dart';
import 'package:test/test.dart';

void main() {
  group('tokenBalancesConfigs', () {
    test('contains the token balance keypaths', () {
      expect(
        tokenBalancesConfigs,
        containsAll([
          ['accountIndex'],
          ['uiTokenAmount', 'decimals'],
          ['uiTokenAmount', 'uiAmount'],
        ]),
      );
    });
  });
}
