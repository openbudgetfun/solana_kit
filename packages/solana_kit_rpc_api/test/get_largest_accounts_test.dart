import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetLargestAccountsConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetLargestAccountsConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config =
          GetLargestAccountsConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes filter when set', () {
      const config =
          GetLargestAccountsConfig(filter: 'circulating');
      final json = config.toJson();
      expect(json['filter'], 'circulating');
    });

    test('toJson includes all fields when all set', () {
      const config = GetLargestAccountsConfig(
        commitment: Commitment.finalized,
        filter: 'nonCirculating',
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'finalized');
      expect(json['filter'], 'nonCirculating');
    });
  });

  group('getLargestAccountsParams', () {
    test('returns empty list when no config', () {
      final params = getLargestAccountsParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getLargestAccountsParams(
        const GetLargestAccountsConfig(
          commitment: Commitment.confirmed,
          filter: 'circulating',
        ),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
      expect(config['filter'], 'circulating');
    });
  });
}
