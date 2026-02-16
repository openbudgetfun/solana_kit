import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('LogsFilter', () {
    test('LogsFilterAll serializes to "all"', () {
      const filter = LogsFilterAll();
      expect(filter.toJson(), 'all');
    });

    test('LogsFilterAllWithVotes serializes to "allWithVotes"', () {
      const filter = LogsFilterAllWithVotes();
      expect(filter.toJson(), 'allWithVotes');
    });

    test('LogsFilterMentions serializes to mentions object', () {
      const filter = LogsFilterMentions(
        Address('11111111111111111111111111111111'),
      );
      expect(filter.toJson(), {
        'mentions': ['11111111111111111111111111111111'],
      });
    });
  });

  group('LogsNotificationsConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = LogsNotificationsConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = LogsNotificationsConfig(commitment: Commitment.confirmed);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });
  });

  group('logsNotificationsParams', () {
    test('returns list with filter only when no config', () {
      final params = logsNotificationsParams(const LogsFilterAll());
      expect(params, hasLength(1));
      expect(params[0], 'all');
    });

    test('returns list with filter and config', () {
      final params = logsNotificationsParams(
        const LogsFilterAllWithVotes(),
        const LogsNotificationsConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], 'allWithVotes');
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
    });

    test('returns list with mentions filter', () {
      final params = logsNotificationsParams(
        const LogsFilterMentions(Address('11111111111111111111111111111111')),
      );
      expect(params, hasLength(1));
      expect(params[0], {
        'mentions': ['11111111111111111111111111111111'],
      });
    });
  });
}
