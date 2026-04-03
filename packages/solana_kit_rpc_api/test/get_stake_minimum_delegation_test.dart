import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetStakeMinimumDelegationConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetStakeMinimumDelegationConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetStakeMinimumDelegationConfig(
        commitment: Commitment.processed,
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'processed');
    });
  });

  group('getStakeMinimumDelegationParams', () {
    test('returns empty list when no config', () {
      final params = getStakeMinimumDelegationParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getStakeMinimumDelegationParams(
        const GetStakeMinimumDelegationConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
