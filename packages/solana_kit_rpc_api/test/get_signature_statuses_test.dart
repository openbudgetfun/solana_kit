import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:test/test.dart';

void main() {
  const sigA = Signature(
    '1111111111111111111111111111111111111111111111111111111111111111',
  );
  const sigB = Signature(
    '2222222222222222222222222222222222222222222222222222222222222222',
  );

  group('GetSignatureStatusesConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetSignatureStatusesConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes searchTransactionHistory when set to true', () {
      const config =
          GetSignatureStatusesConfig(searchTransactionHistory: true);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['searchTransactionHistory'], true);
    });

    test('toJson includes searchTransactionHistory when set to false', () {
      const config =
          GetSignatureStatusesConfig(searchTransactionHistory: false);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['searchTransactionHistory'], false);
    });
  });

  group('getSignatureStatusesParams', () {
    test('returns list with signature array when no config', () {
      final params = getSignatureStatusesParams([sigA, sigB]);
      expect(params, hasLength(1));
      expect(params[0], [sigA.value, sigB.value]);
    });

    test('returns list with signature array and config when config provided', () {
      final params = getSignatureStatusesParams(
        [sigA],
        const GetSignatureStatusesConfig(searchTransactionHistory: true),
      );
      expect(params, hasLength(2));
      expect(params[0], [sigA.value]);
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['searchTransactionHistory'], true);
    });

    test('handles empty signature list', () {
      final params = getSignatureStatusesParams([]);
      expect(params, hasLength(1));
      expect(params[0], isEmpty);
    });
  });
}
