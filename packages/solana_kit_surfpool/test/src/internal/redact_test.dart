import 'package:solana_kit_surfpool/src/internal/redact.dart';
import 'package:test/test.dart';

void main() {
  group('redactUrlCredentials', () {
    test('redacts api-key query parameters', () {
      final redacted = redactUrlCredentials(
        'Timed out waiting for Surfpool RPC at '
        'https://mainnet.helius-rpc.com/?api-key=s3cr3t-key-value',
      );
      expect(redacted, contains('[REDACTED]'));
      expect(redacted, isNot(contains('s3cr3t-key-value')));
    });

    test('redacts userinfo credentials in embedded URLs', () {
      final redacted = redactUrlCredentials(
        'forking from https://user:hunter2@rpc.example.com:8899',
      );
      expect(redacted, isNot(contains('hunter2')));
      expect(redacted, contains('[REDACTED]@rpc.example.com:8899'));
    });

    test('redacts every sensitive query variant', () {
      const keys = ['api-key', 'apikey', 'api_key', 'token', 'password'];
      for (final key in keys) {
        final redacted = redactUrlCredentials('url?$key=abc123');
        expect(redacted, isNot(contains('abc123')), reason: key);
      }
    });

    test('leaves URLs without credentials untouched', () {
      const clean =
          'Timed out waiting for Surfpool RPC at http://127.0.0.1:8899';
      expect(redactUrlCredentials(clean), clean);
    });

    test('redacts credentials inside multi-line process output', () {
      final redacted = redactUrlCredentials(
        '[stdoutLog] surfpool start --rpc-url '
        'https://mainnet.helius-rpc.com/?api-key=leaky-key\n'
        '[stderrLog] listening on 127.0.0.1:8899',
      );
      expect(redacted, isNot(contains('leaky-key')));
      expect(redacted, contains('listening on 127.0.0.1:8899'));
    });
  });
}
