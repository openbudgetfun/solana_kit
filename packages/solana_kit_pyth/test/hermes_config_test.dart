import 'package:solana_kit_pyth/solana_kit_pyth.dart';
import 'package:test/test.dart';

void main() {
  group('HermesConfig', () {
    test('normalizes trailing slashes in the base url', () {
      expect(
        const HermesConfig().normalizedBaseUrl,
        'https://hermes.pyth.network',
      );
      expect(
        const HermesConfig(baseUrl: 'https://h.example.com/').normalizedBaseUrl,
        'https://h.example.com',
      );
    });

    test('exposes the documented defaults', () {
      const config = HermesConfig();
      expect(config.baseUrl, HermesConfig.defaultHermesBaseUrl);
      expect(config.httpRetries, HermesConfig.defaultHermesHttpRetries);
      expect(config.backoffMs, 100);
      expect(config.headers, isEmpty);
      expect(config.accessToken, isNull);
    });

    test('renders a debug representation', () {
      // Deliberately non-const so the constructor runs at runtime.
      final baseUrl = ['https://h.example', '.com'].join();
      final config = HermesConfig(baseUrl: baseUrl);
      expect(
        config.toString(),
        'HermesConfig(baseUrl: https://h.example.com, timeout: 0:00:05.000000)',
      );
    });
  });

  group('HermesEncoding', () {
    test('exposes the wire names', () {
      expect(HermesEncoding.hex.value, 'hex');
      expect(HermesEncoding.base64.value, 'base64');
    });

    test('resolves known encodings', () {
      expect(HermesEncoding.fromName('hex'), HermesEncoding.hex);
      expect(HermesEncoding.fromName('base64'), HermesEncoding.base64);
    });

    test('rejects unknown encodings', () {
      expect(
        () => HermesEncoding.fromName('protobuf'),
        throwsA(
          isA<PythException>().having(
            (e) => e.message,
            'message',
            'Unknown Hermes encoding: protobuf',
          ),
        ),
      );
    });
  });
}
