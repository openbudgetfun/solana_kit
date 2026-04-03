import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetInflationGovernorConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetInflationGovernorConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config =
          GetInflationGovernorConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'finalized');
    });
  });

  group('getInflationGovernorParams', () {
    test('returns empty list when no config', () {
      final params = getInflationGovernorParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getInflationGovernorParams(
        const GetInflationGovernorConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
