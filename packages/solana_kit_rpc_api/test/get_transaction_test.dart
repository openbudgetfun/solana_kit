import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const signature = Signature(
    '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332SVY7Ru6cME43qT35Z7JKpZqCoPaL',
  );

  group('GetTransactionConfig', () {
    test('serializes transaction encoding values', () {
      const config = GetTransactionConfig(
        commitment: Commitment.finalized,
        encoding: TransactionEncoding.jsonParsed,
        maxSupportedTransactionVersion: 0,
      );

      expect(config.toJson(), {
        'commitment': 'finalized',
        'encoding': 'jsonParsed',
        'maxSupportedTransactionVersion': 0,
      });
    });
  });

  group('getTransactionParams', () {
    test('serializes signature and config', () {
      final params = getTransactionParams(
        signature,
        const GetTransactionConfig(encoding: TransactionEncoding.json),
      );

      expect(params[0], signature.value);
      expect(params[1], {'encoding': 'json'});
    });
  });
}
