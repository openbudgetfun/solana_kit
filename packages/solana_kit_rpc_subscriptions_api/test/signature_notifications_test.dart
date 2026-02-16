import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_rpc_subscriptions_api/solana_kit_rpc_subscriptions_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  const testSignature = Signature(
    '5UfDuX7WXYZsNmFYSMYMR7en1JEBhiKQnMGnGHjaZiRhHFvsFa7xBFTmKECymSQJKmNfnSyDBSgjUCAy9AM4L6Sd',
  );

  group('SignatureNotificationsConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = SignatureNotificationsConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = SignatureNotificationsConfig(
        commitment: Commitment.confirmed,
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['commitment'], 'confirmed');
    });

    test('toJson includes enableReceivedNotification when set', () {
      const config = SignatureNotificationsConfig(
        enableReceivedNotification: true,
      );
      final json = config.toJson();
      expect(json, hasLength(1));
      expect(json['enableReceivedNotification'], isTrue);
    });

    test('toJson includes all fields when all set', () {
      const config = SignatureNotificationsConfig(
        commitment: Commitment.finalized,
        enableReceivedNotification: true,
      );
      final json = config.toJson();
      expect(json, hasLength(2));
      expect(json['commitment'], 'finalized');
      expect(json['enableReceivedNotification'], isTrue);
    });
  });

  group('signatureNotificationsParams', () {
    test('returns list with only signature when no config', () {
      final params = signatureNotificationsParams(testSignature);
      expect(params, hasLength(1));
      expect(params[0], testSignature.value);
    });

    test('returns list with signature and config when config provided', () {
      final params = signatureNotificationsParams(
        testSignature,
        const SignatureNotificationsConfig(commitment: Commitment.finalized),
      );
      expect(params, hasLength(2));
      expect(params[0], testSignature.value);
      expect(params[1], isA<Map<String, Object?>>());
    });
  });
}
