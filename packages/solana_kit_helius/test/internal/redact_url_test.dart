import 'package:solana_kit_helius/src/internal/redact_url.dart';
import 'package:test/test.dart';

void main() {
  group('redactUrl', () {
    test('redacts sensitive query parameters and keeps safe parameters', () {
      expect(
        redactUrl('https://example.com/rpc?api-key=secret&cluster=mainnet'),
        'https://example.com/rpc?api-key=%5BREDACTED%5D&cluster=mainnet',
      );
    });

    test('returns URLs without query parameters unchanged', () {
      expect(redactUrl('https://example.com/rpc'), 'https://example.com/rpc');
    });

    test('returns unparsable strings unchanged', () {
      expect(redactUrl('http://[::1'), 'http://[::1');
    });
  });
}
