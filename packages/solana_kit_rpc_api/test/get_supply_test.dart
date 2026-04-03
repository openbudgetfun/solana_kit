import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('GetSupplyConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetSupplyConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetSupplyConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes excludeNonCirculatingAccountsList when set', () {
      const config =
          GetSupplyConfig(excludeNonCirculatingAccountsList: true);
      final json = config.toJson();
      expect(json['excludeNonCirculatingAccountsList'], true);
    });

    test('toJson includes all fields when all set', () {
      const config = GetSupplyConfig(
        commitment: Commitment.finalized,
        excludeNonCirculatingAccountsList: false,
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'finalized');
      expect(json['excludeNonCirculatingAccountsList'], false);
    });
  });

  group('getSupplyParams', () {
    test('returns empty list when no config', () {
      final params = getSupplyParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getSupplyParams(
        const GetSupplyConfig(
          commitment: Commitment.confirmed,
          excludeNonCirculatingAccountsList: true,
        ),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
      expect(config['excludeNonCirculatingAccountsList'], true);
    });
  });
}
