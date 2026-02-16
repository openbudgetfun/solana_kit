import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetBlockConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetBlockConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetBlockConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json['commitment'], 'finalized');
    });

    test('toJson includes encoding when set', () {
      const config = GetBlockConfig(encoding: 'json');
      final json = config.toJson();
      expect(json['encoding'], 'json');
    });

    test('toJson includes maxSupportedTransactionVersion when set', () {
      const config = GetBlockConfig(maxSupportedTransactionVersion: 0);
      final json = config.toJson();
      expect(json['maxSupportedTransactionVersion'], 0);
    });

    test('toJson includes rewards when set', () {
      const config = GetBlockConfig(rewards: false);
      final json = config.toJson();
      expect(json['rewards'], false);
    });

    test('toJson includes transactionDetails when set', () {
      const config = GetBlockConfig(transactionDetails: 'full');
      final json = config.toJson();
      expect(json['transactionDetails'], 'full');
    });

    test('toJson includes all fields when all set', () {
      const config = GetBlockConfig(
        commitment: Commitment.confirmed,
        encoding: 'jsonParsed',
        maxSupportedTransactionVersion: 0,
        rewards: true,
        transactionDetails: 'accounts',
      );
      final json = config.toJson();
      expect(json, hasLength(5));
      expect(json['commitment'], 'confirmed');
      expect(json['encoding'], 'jsonParsed');
      expect(json['maxSupportedTransactionVersion'], 0);
      expect(json['rewards'], true);
      expect(json['transactionDetails'], 'accounts');
    });
  });

  group('getBlockParams', () {
    test('returns list with only slot when no config', () {
      final params = getBlockParams(BigInt.from(12345));
      expect(params, hasLength(1));
      expect(params[0], BigInt.from(12345));
    });

    test('returns list with slot and config when config provided', () {
      final params = getBlockParams(
        BigInt.from(100),
        const GetBlockConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], BigInt.from(100));
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });

    test('slot is passed as BigInt', () {
      final slot = BigInt.from(999999999);
      final params = getBlockParams(slot);
      expect(params[0], slot);
    });
  });
}
