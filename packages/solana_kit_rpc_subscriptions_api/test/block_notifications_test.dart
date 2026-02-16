import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('BlockNotificationsFilter', () {
    test('BlockFilterAll serializes to "all"', () {
      const filter = BlockFilterAll();
      expect(filter.toJson(), 'all');
    });

    test('BlockFilterMentionsAccountOrProgram serializes to object', () {
      const filter = BlockFilterMentionsAccountOrProgram(
        Address('11111111111111111111111111111111'),
      );
      expect(filter.toJson(), {
        'mentionsAccountOrProgram': '11111111111111111111111111111111',
      });
    });
  });

  group('BlockNotificationsConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = BlockNotificationsConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = BlockNotificationsConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'finalized');
    });

    test('toJson includes encoding when set', () {
      const config = BlockNotificationsConfig(encoding: 'base64');
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['encoding'], 'base64');
    });

    test('toJson includes maxSupportedTransactionVersion when set', () {
      const config = BlockNotificationsConfig(
        maxSupportedTransactionVersion: 0,
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['maxSupportedTransactionVersion'], 0);
    });

    test('toJson includes showRewards when set', () {
      const config = BlockNotificationsConfig(showRewards: false);
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['showRewards'], isFalse);
    });

    test('toJson includes transactionDetails when set', () {
      const config = BlockNotificationsConfig(transactionDetails: 'none');
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['transactionDetails'], 'none');
    });

    test('toJson includes all fields when all set', () {
      const config = BlockNotificationsConfig(
        commitment: Commitment.confirmed,
        encoding: 'json',
        maxSupportedTransactionVersion: 0,
        showRewards: true,
        transactionDetails: 'full',
      );
      final json = config.toJson();
      expect(json, hasLength(5));
      expect(json['commitment'], 'confirmed');
      expect(json['encoding'], 'json');
      expect(json['maxSupportedTransactionVersion'], 0);
      expect(json['showRewards'], isTrue);
      expect(json['transactionDetails'], 'full');
    });
  });

  group('blockNotificationsParams', () {
    test('returns list with filter only when no config', () {
      final params = blockNotificationsParams(const BlockFilterAll());
      expect(params, hasLength(1));
      expect(params[0], 'all');
    });

    test('returns list with filter and config', () {
      final params = blockNotificationsParams(
        const BlockFilterAll(),
        const BlockNotificationsConfig(
          commitment: Commitment.finalized,
          transactionDetails: 'none',
        ),
      );
      expect(params, hasLength(2));
      expect(params[0], 'all');
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['commitment'], 'finalized');
      expect(config['transactionDetails'], 'none');
    });

    test('returns list with mentionsAccountOrProgram filter', () {
      final params = blockNotificationsParams(
        const BlockFilterMentionsAccountOrProgram(
          Address('11111111111111111111111111111111'),
        ),
      );
      expect(params, hasLength(1));
      expect(params[0], {
        'mentionsAccountOrProgram': '11111111111111111111111111111111',
      });
    });
  });
}
