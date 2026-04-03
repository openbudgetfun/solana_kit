import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testAddress = Address('11111111111111111111111111111111');

  group('GetVoteAccountsConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = GetVoteAccountsConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = GetVoteAccountsConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes delinquentSlotDistance when set', () {
      final config =
          GetVoteAccountsConfig(delinquentSlotDistance: BigInt.from(3));
      final json = config.toJson();
      expect(json['delinquentSlotDistance'], BigInt.from(3));
    });

    test('toJson includes keepUnstakedDelinquents when set', () {
      const config = GetVoteAccountsConfig(keepUnstakedDelinquents: true);
      final json = config.toJson();
      expect(json['keepUnstakedDelinquents'], true);
    });

    test('toJson includes votePubkey when set', () {
      const config = GetVoteAccountsConfig(votePubkey: testAddress);
      final json = config.toJson();
      expect(json['votePubkey'], '11111111111111111111111111111111');
    });

    test('toJson includes all fields when all set', () {
      final config = GetVoteAccountsConfig(
        commitment: Commitment.finalized,
        delinquentSlotDistance: BigInt.from(5),
        keepUnstakedDelinquents: false,
        votePubkey: testAddress,
      );
      final json = config.toJson();
      expect(json, hasLength(4));
      expect(json['commitment'], 'finalized');
      expect(json['delinquentSlotDistance'], BigInt.from(5));
      expect(json['keepUnstakedDelinquents'], false);
      expect(json['votePubkey'], '11111111111111111111111111111111');
    });
  });

  group('getVoteAccountsParams', () {
    test('returns empty list when no config', () {
      final params = getVoteAccountsParams();
      expect(params, isEmpty);
    });

    test('returns list with config map when config provided', () {
      final params = getVoteAccountsParams(
        const GetVoteAccountsConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(1));
      expect(params[0], isA<Map<String, Object?>>());
      final config = params[0]! as Map<String, Object?>;
      expect(config['commitment'], 'confirmed');
    });
  });
}
