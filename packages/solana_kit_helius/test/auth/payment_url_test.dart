import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('payment URL helpers', () {
    test('falls back to the default payment host', () {
      expect(resolvePaymentHost(environment: const {}), heliusPaymentHost);
    });

    test('uses HELIUS_PAYMENT_HOST when set', () {
      expect(
        resolvePaymentHost(
          environment: const {
            'HELIUS_PAYMENT_HOST': 'https://staging.example.com',
          },
        ),
        'https://staging.example.com',
      );
    });

    test('explicit override beats environment and default host', () {
      expect(
        resolvePaymentHost(
          override: 'https://override.example.com',
          environment: const {
            'HELIUS_PAYMENT_HOST': 'https://staging.example.com',
          },
        ),
        'https://override.example.com',
      );
    });

    test('ignores empty environment value', () {
      expect(
        resolvePaymentHost(environment: const {'HELIUS_PAYMENT_HOST': ''}),
        heliusPaymentHost,
      );
    });

    test('strips trailing slash from override and environment values', () {
      expect(
        resolvePaymentHost(override: 'https://x.example/'),
        'https://x.example',
      );
      expect(
        resolvePaymentHost(
          environment: const {'HELIUS_PAYMENT_HOST': 'https://y.example/'},
        ),
        'https://y.example',
      );
    });

    test('buildPaymentUrl composes host and payment intent id', () {
      expect(buildPaymentUrl('pi_abc'), '$heliusPaymentHost/pay/pi_abc');
      expect(
        buildPaymentUrl('pi_xyz', hostOverride: 'https://staging.example.com'),
        'https://staging.example.com/pay/pi_xyz',
      );
    });
  });
}
