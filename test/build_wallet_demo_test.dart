import 'package:test/test.dart';

import '../scripts/build_wallet_demo.dart';

void main() {
  group('optionValue', () {
    test('parses space separated flags', () {
      expect(
        optionValue(['--base-path', '/solana_kit/'], '--base-path'),
        '/solana_kit/',
      );
    });

    // Regression: the `--flag=value` spelling was accidentally dropped when
    // the parser was simplified, silently rebuilding the demo with `/` even
    // though devenv and the smoke script pass the value in this spelling.
    test('parses equals separated flags', () {
      expect(
        optionValue(['--base-path=/solana_kit/'], '--base-path'),
        '/solana_kit/',
      );
    });

    test('returns null when the flag is absent', () {
      expect(optionValue(<String>[], '--base-path'), isNull);
      expect(optionValue(['--other', 'value'], '--base-path'), isNull);
    });

    test('returns null when the flag has no value', () {
      expect(optionValue(['--base-path'], '--base-path'), isNull);
    });
  });

  group('composeDemoBaseHref', () {
    test('nests wallet-demo under the base path', () {
      expect(composeDemoBaseHref('/solana_kit/'), '/solana_kit/wallet-demo/');
    });

    test('normalizes missing slashes', () {
      expect(composeDemoBaseHref('solana_kit'), '/solana_kit/wallet-demo/');
      expect(composeDemoBaseHref('/solana_kit'), '/solana_kit/wallet-demo/');
    });

    test('root base paths yield /wallet-demo/', () {
      expect(composeDemoBaseHref('/'), '/wallet-demo/');
      expect(composeDemoBaseHref(''), '/wallet-demo/');
    });
  });
}
