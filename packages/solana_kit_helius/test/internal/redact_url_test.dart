import 'package:solana_kit_helius/src/internal/redact_url.dart';
import 'package:test/test.dart';

void main() {
  group('redactUrlCredentials', () {
    test('redacts api-key query parameters anywhere in the text', () {
      expect(
        redactUrlCredentials(
          'denied for https://mainnet.helius-rpc.com/?api-key=leaky-key',
        ),
        isNot(contains('leaky-key')),
      );
    });

    test('redacts user-info credentials anywhere in the text', () {
      final redacted = redactUrlCredentials(
        'gateway error contacting https://user:hunter2@rpc.example.com/v0',
      );
      expect(redacted, isNot(contains('hunter2')));
      expect(redacted, contains('[REDACTED]@rpc.example.com'));
    });

    test('leaves text without credentials untouched', () {
      const clean = 'denied';
      expect(redactUrlCredentials(clean), clean);
    });
  });
}
